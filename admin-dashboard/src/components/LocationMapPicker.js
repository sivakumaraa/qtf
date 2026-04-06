import React, { useState, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMapEvents, Circle } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { Search, MapPin, X, Navigation } from 'lucide-react';

// Fix default marker icons
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

const LocationMapPicker = ({ 
  latitude = 20.5937, 
  longitude = 78.9629, 
  onLocationSelect = () => {},
  locationName = '',
  isOptional = false,
  onSkipLocation = () => {}
}) => {
  const [mapLat, setMapLat] = useState(parseFloat(latitude) || 20.5937);
  const [mapLng, setMapLng] = useState(parseFloat(longitude) || 78.9629);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [searching, setSearching] = useState(false);
  const [showResults, setShowResults] = useState(false);
  const [currentLat, setCurrentLat] = useState(null);
  const [currentLng, setCurrentLng] = useState(null);
  const [geoLoading, setGeoLoading] = useState(false);
  const debounceTimer = useRef(null);

  // Get user's current location on component mount
  React.useEffect(() => {
    if (navigator.geolocation) {
      setGeoLoading(true);
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          setCurrentLat(latitude);
          setCurrentLng(longitude);
          setGeoLoading(false);
        },
        (error) => {
          console.warn('Geolocation error:', error.message);
          setGeoLoading(false);
        },
        { timeout: 5000, enableHighAccuracy: false }
      );
    }
  }, []);

  // Debounced search function
  const performSearch = async (query) => {
    if (!query.trim()) {
      setSearchResults([]);
      setShowResults(false);
      return;
    }

    setSearching(true);
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=8`
      );
      const data = await response.json();
      if (data && data.length > 0) {
        setSearchResults(data);
        setShowResults(true);
      } else {
        setSearchResults([]);
        setShowResults(false);
      }
    } catch (error) {
      console.error('Search error:', error);
      setSearchResults([]);
    } finally {
      setSearching(false);
    }
  };

  // Handle input change with debouncing
  const handleSearchInputChange = (e) => {
    const query = e.target.value;
    setSearchQuery(query);

    // Clear previous timer
    if (debounceTimer.current) {
      clearTimeout(debounceTimer.current);
    }

    // Set new timer for search
    debounceTimer.current = setTimeout(() => {
      performSearch(query);
    }, 300); // Search after 300ms of no typing
  };

  // Component to handle map clicks
  const LocationMarker = () => {
    useMapEvents({
      click(e) {
        const { lat, lng } = e.latlng;
        setMapLat(lat);
        setMapLng(lng);
        onLocationSelect({
          lat: lat.toFixed(6),
          lng: lng.toFixed(6),
          location: `${lat.toFixed(6)}, ${lng.toFixed(6)}`
        });
      },
    });

    return mapLat && mapLng && (
      <Marker position={[mapLat, mapLng]}>
        <Popup>
          <div className="text-center">
            <p className="font-semibold text-sm">Selected Location</p>
            <p className="text-xs">{mapLat.toFixed(6)}, {mapLng.toFixed(6)}</p>
          </div>
        </Popup>
      </Marker>
    );
  };

  // Handle search result selection
  const handleSelectSearchResult = (result) => {
    const lat = parseFloat(result.lat);
    const lng = parseFloat(result.lon);

    setMapLat(lat);
    setMapLng(lng);
    setSearchQuery(result.display_name);
    setShowResults(false);
    setSearchResults([]);

    onLocationSelect({
      lat: lat.toFixed(6),
      lng: lng.toFixed(6),
      location: result.display_name
    });
  };

  const handleClearSearch = () => {
    setSearchQuery('');
    setSearchResults([]);
    setShowResults(false);
  };

  const useCurrentLocation = () => {
    if (currentLat && currentLng) {
      setMapLat(currentLat);
      setMapLng(currentLng);
      onLocationSelect({
        lat: currentLat.toFixed(6),
        lng: currentLng.toFixed(6),
        location: `${currentLat.toFixed(6)}, ${currentLng.toFixed(6)}`
      });
      setSearchQuery('');
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      if (searchResults.length > 0) {
        handleSelectSearchResult(searchResults[0]);
      }
    }
  };

  return (
    <div className="space-y-3">
      {/* Search Section */}
      <div className="relative z-50">
        <div className="flex justify-between items-end mb-2">
          <label className="block text-sm font-semibold text-gray-700">
            Search Location
          </label>
          {currentLat && currentLng && (
            <button
              type="button"
              onClick={useCurrentLocation}
              disabled={geoLoading}
              className="flex items-center gap-1 text-xs bg-blue-50 hover:bg-blue-100 text-blue-600 px-3 py-1 rounded-lg border border-blue-200 transition-colors disabled:opacity-50"
              title="Use your current location"
            >
              <Navigation className="w-3 h-3" />
              Use Current
            </button>
          )}
        </div>
        <div className="flex gap-2 relative">
          <div className="flex-1 relative">
            <input
              type="text"
              value={searchQuery}
              onChange={handleSearchInputChange}
              onKeyPress={handleKeyPress}
              onFocus={() => searchResults.length > 0 && setShowResults(true)}
              placeholder="Search by address, city, or landmark..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none pr-10"
            />
            
            {/* Clear button */}
            {searchQuery && (
              <button
                type="button"
                onClick={handleClearSearch}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                <X className="w-4 h-4" />
              </button>
            )}
            
            {/* Search Results Dropdown - Position fixed to avoid being hidden by map */}
            {showResults && searchResults.length > 0 && (
              <div className="absolute top-full left-0 right-0 bg-white border border-gray-300 rounded-lg mt-1 shadow-xl z-50 max-h-64 overflow-y-auto">
                {searchResults.map((result, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => handleSelectSearchResult(result)}
                    className="w-full text-left px-4 py-3 hover:bg-blue-50 border-b border-gray-200 last:border-b-0 transition-colors"
                  >
                    <div className="font-semibold text-gray-900 text-sm">{result.name || result.display_name.split(',')[0]}</div>
                    <div className="text-xs text-gray-600 truncate">{result.display_name}</div>
                  </button>
                ))}
              </div>
            )}

            {/* "No results" message */}
            {showResults && searchResults.length === 0 && searchQuery && !searching && (
              <div className="absolute top-full left-0 right-0 bg-white border border-gray-300 rounded-lg mt-1 shadow-xl z-50">
                <div className="px-4 py-3 text-sm text-gray-600">
                  No results found for "{searchQuery}"
                </div>
              </div>
            )}
          </div>

          {/* Search status indicator */}
          {searching && (
            <div className="flex items-center px-3 text-gray-400">
              <div className="animate-spin">
                <Search className="w-4 h-4" />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Map Section */}
      <div className="relative z-10">
        <label className="block text-sm font-semibold text-gray-700 mb-2">
          Click on Map to Select Location
        </label>
        <MapContainer
          center={[mapLat, mapLng]}
          zoom={13}
          scrollWheelZoom={true}
          className="w-full h-64 rounded-lg border border-gray-300 shadow-sm"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {/* Current location marker circle (if available) */}
          {currentLat && currentLng && (
            <>
              <Circle
                center={[currentLat, currentLng]}
                radius={50}
                pathOptions={{
                  color: '#10b981',
                  fillColor: '#d1fae5',
                  fillOpacity: 0.2,
                  weight: 2
                }}
              />
              <Marker 
                position={[currentLat, currentLng]}
                icon={L.icon({
                  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
                  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
                  iconSize: [25, 41],
                  iconAnchor: [12, 41],
                  popupAnchor: [1, -34],
                  shadowSize: [41, 41]
                })}
              >
                <Popup>
                  <div className="text-center">
                    <p className="font-semibold text-sm text-green-600">Your Current Location</p>
                    <p className="text-xs">{currentLat.toFixed(6)}, {currentLng.toFixed(6)}</p>
                  </div>
                </Popup>
              </Marker>
            </>
          )}
          <LocationMarker />
        </MapContainer>
      </div>

      {/* Latitude & Longitude Input Fields */}
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">
            Latitude {!isOptional && '*'}
          </label>
          <input
            type="number"
            step="0.000001"
            value={mapLat}
            onChange={(e) => {
              const value = e.target.value;
              if (value) {
                const lat = parseFloat(value);
                setMapLat(lat);
                onLocationSelect({
                  lat: lat.toFixed(6),
                  lng: mapLng.toFixed(6),
                  location: `${lat.toFixed(6)}, ${mapLng.toFixed(6)}`
                });
              }
            }}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono text-sm"
            placeholder="e.g., 12.9716"
            required={!isOptional}
          />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">
            Longitude {!isOptional && '*'}
          </label>
          <input
            type="number"
            step="0.000001"
            value={mapLng}
            onChange={(e) => {
              const value = e.target.value;
              if (value) {
                const lng = parseFloat(value);
                setMapLng(lng);
                onLocationSelect({
                  lat: mapLat.toFixed(6),
                  lng: lng.toFixed(6),
                  location: `${mapLat.toFixed(6)}, ${lng.toFixed(6)}`
                });
              }
            }}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none font-mono text-sm"
            placeholder="e.g., 77.5946"
            required={!isOptional}
          />
        </div>
      </div>

      {/* Skip GPS Button (if optional) */}
      {isOptional && (
        <button
          type="button"
          onClick={() => {
            setMapLat(20.5937);
            setMapLng(78.9629);
            onSkipLocation();
          }}
          className="w-full px-4 py-2 border border-gray-300 text-gray-600 font-medium rounded-lg hover:bg-gray-50 transition-colors"
          title="Skip GPS entry and add customer without location"
        >
          Skip Location Entry
        </button>
      )}

      {/* Info */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-xs text-blue-800 flex items-start gap-2">
        <MapPin className="w-4 h-4 flex-shrink-0 mt-0.5" />
        <div>
          <p className="font-semibold mb-1">Location Selection Tips:</p>
          <ul className="list-disc list-inside space-y-0.5">
            <li>Use "Current" button to auto-fill your current coordinates (green marker on map)</li>
            <li>Type to search for a location (autocomplete like Google Maps)</li>
            <li>Results appear as you type with a 300ms delay</li>
            <li>Press Enter or click a result to select it</li>
            <li>Click anywhere on the map to select that location (blue marker)</li>
            <li>Edit latitude/longitude fields directly if needed</li>
            {isOptional && <li>Use "Skip Location Entry" button to add customer without GPS coordinates</li>}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default LocationMapPicker;
