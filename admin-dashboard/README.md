# QuarryForce Tracker - Admin Dashboard

## Overview

This is the React-based admin dashboard for QuarryForce Tracker, providing complete management of sales targets, rep performance monitoring, and fraud detection capabilities.

## Features

### 1. **Dashboard Overview**

- Real-time statistics on active reps and sales targets
- Quick summary of bonuses distributed this month
- Welcome message and quick action buttons
- System health status

### 2. **Target Management**

- View all sales targets across representatives
- Create new targets with customizable incentive structures
- Update existing targets per rep
- Track target status and compliance

### 3. **Sales Recording**

- Record monthly sales volumes for reps
- Auto-calculated bonus and penalty system
- Real-time compensation display
- Results card showing breakdown of earnings/deductions

### 4. **Fraud Alerts**

- Monitor active fraud alerts with severity scoring
- View GPS spoofing detection results
- Track suspicious activity alerts
- Anti-cheating protocols status dashboard
- One-click account blocking for confirmed fraud

### 5. **Analytics Dashboard**

- Performance metrics for all reps
- Top performer rankings
- Underperformer identification
- Comprehensive performance table with all calculations
- Bonus/penalty distribution analysis
- Compliance rate tracking

## Installation

### Prerequisites

- Node.js 16.x or higher
- npm or yarn package manager
- Backend API running on localhost:3000

### Setup Steps

1. **Navigate to admin-dashboard directory:**

```bash
cd admin-dashboard
```

2. **Install dependencies:**

```bash
npm install
```

3. **Configure API endpoint** (edit `src/api/client.js` if needed):

```javascript
const BASE_URL = "http://localhost:3000"; // Update if backend runs on different port
```

4. **Start development server:**

```bash
npm start
```

The dashboard will open on `http://localhost:3000` (or next available port if 3000 is occupied).

## Project Structure

```
admin-dashboard/
├── public/
│   └── index.html          # HTML entry point
├── src/
│   ├── api/
│   │   └── client.js       # API client with all endpoints
│   ├── components/
│   │   ├── Dashboard.js    # Main container with tab navigation
│   │   ├── Overview.js     # Statistics dashboard
│   │   ├── TargetManagement.js  # CRUD operations for targets
│   │   ├── SalesRecording.js    # Sales entry & compensation display
│   │   ├── FraudAlerts.js       # Fraud monitoring
│   │   └── Analytics.js    # Performance metrics & charts
│   ├── App.js              # Main React component
│   ├── App.css             # Application styles
│   ├── index.js            # React entry point
│   └── index.css           # Global styles
├── package.json            # Dependencies and scripts
└── .gitignore             # Git ignore rules
```

## Available Scripts

### `npm start`

Runs the app in development mode.
Open [http://localhost:3000](http://localhost:3000) to view in browser.

### `npm build`

Builds the app for production to the `build` folder.

### `npm test`

Runs test suite (if configured).

## API Integration

The dashboard integrates with these backend endpoints:

### Rep Targets APIs

- `GET /api/admin/rep-targets` - Get all targets
- `GET /api/admin/rep-targets/:rep_id` - Get target for specific rep
- `POST /api/admin/rep-targets` - Create new target
- `PUT /api/admin/rep-targets/:rep_id` - Update target

### Sales Progress APIs

- `GET /api/admin/rep-progress/:rep_id` - Get rep's progress
- `POST /api/admin/rep-progress/update` - Record sales (auto-calculates bonus/penalty)

### Admin APIs

- `GET /api/admin/reps` - Get all representatives
- `GET /api/admin/customers` - Get all customers
- `POST /api/admin/reset-device` - Reset device binding for rep

## Component Details

### Overview.js

Fetches and displays:

- Total active targets
- Number of active reps
- Total combined sales targets
- Bonus distribution this month

### TargetManagement.js

Allows admins to:

- Create new targets with customizable incentive rates
- View all targets in searchable table
- Edit existing targets
- Delete targets (soft delete - marks as inactive)

### SalesRecording.js

Workflow:

1. Select rep from dropdown
2. Enter sales volume (m³)
3. Select month
4. Click "Calculate Compensation"
5. View auto-calculated bonus/penalty/net compensation

Example: If target is 300m³ and rep achieved 350m³ at ₹5/m³ incentive, shows +₹250 bonus.

### FraudAlerts.js

Features:

- Active fraud alerts with severity scores
- Alert details (GPS spoofing, suspicious patterns, etc.)
- Block account buttons for confirmed fraud
- Anti-cheating protocols status
- Fraud prevention analytics

### Analytics.js

Includes:

- Key performance metrics
- Top 3 performer rankings
- Underperformer alerts
- Full performance table (target vs achieved, bonus, penalty, net)
- Compliance rate tracking
- Bonus/penalty distribution analysis

## Styling

Uses **TailwindCSS** for responsive, utility-first styling:

- Dark mode compatible
- Mobile responsive
- Smooth animations and transitions
- Gradient backgrounds for visual hierarchy

### Custom CSS Classes

Located in `src/App.css`:

- `.tab-button` - Tab navigation buttons
- `.stat-card` - Statistics cards
- `.btn-primary`, `.btn-danger`, etc. - Button variants
- `.error-message`, `.success-message` - Alert messages

## Development Tips

1. **API Debugging:**
   - Check browser console (F12) for API errors
   - Verify backend is running on localhost:3000
   - Check CORS configuration in backend

2. **State Management:**
   - Components use React hooks (useState, useEffect)
   - Each component manages its own state
   - Data flows top-down from parent to child

3. **Error Handling:**
   - All API calls wrapped in try/catch
   - Error messages displayed to user
   - Loading states during data fetch

4. **Performance:**
   - Components render only when dependencies change
   - API calls made on component mount with useEffect
   - No unnecessary re-renders

## Deployment

### Vercel (Recommended)

1. Push repo to GitHub
2. Connect to Vercel in dashboard
3. Configure environment variables:
   ```
   REACT_APP_API_BASE_URL=https://your-backend-api.com
   ```
4. Deploy with single click

### Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npx", "serve", "-s", "build"]
```

## Environment Variables

Create a `.env` file in the root directory:

```
REACT_APP_API_BASE_URL=http://localhost:3000
REACT_APP_API_TIMEOUT=30000
REACT_APP_DEBUG_MODE=false
```

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Troubleshooting

### Components not loading

- Check browser console for errors
- Verify backend API is running
- Confirm API endpoints are accessible

### Styling issues

- Clear browser cache
- Verify TailwindCSS is properly configured
- Check for CSS class conflicts

### API 404 errors

- Verify rep_id exists in database
- Check request payload format
- Confirm backend is running

## Future Enhancements

- [ ] Real-time WebSocket updates
- [ ] User authentication and authorization
- [ ] Export to CSV/Excel
- [ ] Chart.js integration for visualization
- [ ] Dark mode toggle
- [ ] Multi-language support
- [ ] Mobile app synchronization

## Support

For issues or questions about the admin dashboard:

1. Check SYSTEM_ARCHITECTURE_GUIDE.md for technical details
2. Review IMPLEMENTATION_ROADMAP_1-5.md for phase details
3. Check backend DEVELOPMENT_STATUS.md for API documentation

## License

Proprietary - QuarryForce Tracker © 2024
