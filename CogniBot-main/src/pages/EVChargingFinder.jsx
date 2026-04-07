import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap, useMapEvents } from 'react-leaflet';
import { collection, onSnapshot, doc, updateDoc, addDoc, serverTimestamp, getDoc, runTransaction } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { useAuth } from '../contexts/AuthContext';
import { Zap, BatteryCharging, Loader2, IndianRupee, MapPin, Gauge, ShieldCheck } from 'lucide-react';
import toast from 'react-hot-toast';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Icon Setup
const createIcon = (color) => new L.DivIcon({
  html: `<svg width="30" height="30" viewBox="0 0 24 24" fill="${color}" stroke="white" stroke-width="2" xmlns="http://www.w3.org/2000/svg"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>`,
  className: "", iconSize: [30, 30], iconAnchor: [15, 30], popupAnchor: [0, -30]
});

const stationIcon = createIcon('#16a34a'); // Green for stations
const userIcon = createIcon('#3b82f6');    // Blue for YOU

// FIXED: Component now actually displays the blue pin
function MyLocationMarker() {
  const [position, setPosition] = useState(null);
  const map = useMap();

  useEffect(() => {
    // 1. Find user location
    map.locate().on("locationfound", function (e) {
      setPosition(e.latlng); // Set state to show the marker
      map.flyTo(e.latlng, map.getZoom()); // Center map on user
    });
  }, [map]);

  // 2. Render the Blue Pin if position is found
  return position === null ? null : (
    <Marker position={position} icon={userIcon}>
      <Popup>
        <div className="font-bold text-blue-600">You are here</div>
      </Popup>
    </Marker>
  );
}

const EVChargingFinder = () => {
  const [stations, setStations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [bookingLoading, setBookingLoading] = useState(false);
  const { currentUser } = useAuth();

  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'stations'), (snap) => {
      setStations(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const handleBookSlot = async (station) => {
    if (!currentUser) return toast.error("Please login to book");
    if (bookingLoading) return;

    setBookingLoading(true);
    try {
      // Use Transaction for atomic money deduction and slot update
      await runTransaction(db, async (transaction) => {
        const userRef = doc(db, 'users', currentUser.uid);
        const stationRef = doc(db, 'stations', station.id);

        const userSnap = await transaction.get(userRef);
        const stationSnap = await transaction.get(stationRef);

        if (!userSnap.exists()) throw "User profile not found!";
        
        const userData = userSnap.data();
        const stationData = stationSnap.data();

        const currentBalance = Number(userData.walletBalance || 0); // Root balance
        const cost = Number(stationData.pricePerHour || 0);
        const availableSlots = Number(stationData.availableSlots || 0);

        if (currentBalance < cost) throw `Insufficient Balance (Have ₹${currentBalance})`;
        if (availableSlots <= 0) throw "No slots available!";

        // Update Wallet & Slots
        transaction.update(userRef, { walletBalance: currentBalance - cost });
        transaction.update(stationRef, { availableSlots: availableSlots - 1 });

        // Create Booking
        const bookingRef = doc(collection(db, 'bookings'));
        transaction.set(bookingRef, {
          userId: currentUser.uid,
          userName: userData.name || currentUser.displayName || "User",
          stationId: station.id,
          stationName: stationData.name,
          amount: cost,
          status: 'active',
          createdAt: serverTimestamp()
        });
      });

      toast.success("Booking Successful!");
    } catch (err) {
      console.error(err);
      toast.error(typeof err === 'string' ? err : "Transaction failed");
    } finally {
      setBookingLoading(false);
    }
  };

  if (loading) return <div className="h-screen flex items-center justify-center"><Loader2 className="animate-spin text-green-600" size={40} /></div>;

  return (
    <div className="flex w-full mt-24 h-[calc(100vh-96px)] overflow-hidden bg-white relative">
      <aside className="w-80 md:w-96 flex flex-col border border-slate-200 z-[400] bg-white shrink-0 mt-4 ml-4 mb-4 rounded-3xl shadow-2xl overflow-hidden">
        <div className="p-6 border-b bg-white">
          <h2 className="text-2xl font-black text-slate-900 flex items-center gap-2">
            <Zap className="text-green-600" fill="#16a34a" size={24} /> Ahmedabad Hubs
          </h2>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-50/50">
          {stations.map(s => (
            <div key={s.id} className="p-5 bg-white border-2 border-slate-100 rounded-2xl shadow-sm hover:border-green-500 transition-all group">
              <h3 className="font-extrabold text-slate-900 group-hover:text-green-600">{s.name}</h3>
              <div className="grid grid-cols-2 gap-2 my-4">
                <div className="bg-slate-50 p-2 rounded-xl border border-slate-100">
                  <p className="text-[8px] font-black text-slate-400 uppercase">Hardware</p>
                  <p className="text-xs font-bold text-slate-700 truncate">{s.chargerType}</p>
                </div>
                <div className="bg-slate-50 p-2 rounded-xl border border-slate-100">
                  <p className="text-[8px] font-black text-slate-400 uppercase">Slots</p>
                  <p className="text-xs font-bold text-green-600">{s.availableSlots} Left</p>
                </div>
              </div>
              <div className="flex items-center justify-between pt-3 border-t border-dashed border-slate-200">
                <span className="text-lg font-black text-slate-900"><IndianRupee size={16} />{s.pricePerHour}</span>
                <button 
                  onClick={() => handleBookSlot(s)} 
                  disabled={bookingLoading || s.availableSlots <= 0} 
                  className="px-6 py-2 bg-slate-900 text-white rounded-xl font-bold text-xs hover:bg-green-600 transition-all"
                >
                  {bookingLoading ? <Loader2 className="animate-spin" size={16} /> : 'Book'}
                </button>
              </div>
            </div>
          ))}
        </div>
      </aside>

      <main className="flex-1 relative z-0">
        <MapContainer center={[23.0225, 72.5714]} zoom={13} style={{ height: '100%', width: '100%' }}>
          <TileLayer url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png" />
          
          {/* USER LOCATION PIN */}
          <MyLocationMarker />

          {/* STATION PINS */}
          {stations.map(s => (
            <Marker key={s.id} position={[s.lat, s.lng]} icon={stationIcon}>
              <Popup>
                <div className="p-2 min-w-[120px]">
                  <p className="font-bold text-slate-900 mb-1">{s.name}</p>
                  <button onClick={() => handleBookSlot(s)} className="w-full bg-slate-900 text-white py-1 rounded font-bold text-[10px]">Confirm Booking</button>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </main>
    </div>
  );
};

export default EVChargingFinder;