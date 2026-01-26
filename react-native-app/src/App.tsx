import React from 'react';
import {StatusBar} from 'react-native';
import AppNavigator from './navigation/AppNavigator';

const App = () => {
  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor="#1a1f1d" />
      <AppNavigator />
    </>
  );
};

export default App;
