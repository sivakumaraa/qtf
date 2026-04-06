// Configuration constants for the admin dashboard

// Currency Configuration
export const CURRENCY = {
  // Symbol displayed for currency (INR = Indian Rupee)
  SYMBOL: '₹',
  CODE: 'INR',
  NAME: 'Indian Rupee',
  
  // Decimal places for currency display
  DECIMAL_PLACES: 2,
  
  // Format function for currency display
  format: (amount) => {
    if (amount === null || amount === undefined) return `${CURRENCY.SYMBOL}0`;
    return `${CURRENCY.SYMBOL}${Number(amount).toLocaleString('en-IN', {
      minimumFractionDigits: CURRENCY.DECIMAL_PLACES,
      maximumFractionDigits: CURRENCY.DECIMAL_PLACES,
    })}`;
  },
  
  // Format function for currency with sign (+ or -)
  formatWithSign: (amount) => {
    if (amount === null || amount === undefined) return `${CURRENCY.SYMBOL}0`;
    const isNegative = amount < 0;
    const absAmount = Math.abs(amount);
    const formatted = `${CURRENCY.SYMBOL}${Number(absAmount).toLocaleString('en-IN', {
      minimumFractionDigits: CURRENCY.DECIMAL_PLACES,
      maximumFractionDigits: CURRENCY.DECIMAL_PLACES,
    })}`;
    return isNegative ? `-${formatted}` : `+${formatted}`;
  },
};

// API Configuration
export const API_CONFIG = {
  BASE_URL: process.env.REACT_APP_API_URL || 'https://perspectivetechnology.in',
  TIMEOUT: 10000,
};

// UI Configuration
export const UI_CONFIG = {
  ITEMS_PER_PAGE: 10,
  REFRESH_INTERVAL: 30000, // 30 seconds
  ANIMATION_DURATION: 300, // milliseconds
};

// Number formats for different regions
export const NUMBER_FORMATS = {
  IN: {
    locale: 'en-IN',
    symbol: '₹',
  },
  US: {
    locale: 'en-US',
    symbol: '$',
  },
  EU: {
    locale: 'de-DE',
    symbol: '€',
  },
};
