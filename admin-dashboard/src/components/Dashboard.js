import React from 'react';
import { Outlet } from 'react-router-dom';
import PremiumLayout from './PremiumLayout';

const Dashboard = () => {
  return (
    <PremiumLayout>
      <Outlet />
    </PremiumLayout>
  );
};

export default Dashboard;

