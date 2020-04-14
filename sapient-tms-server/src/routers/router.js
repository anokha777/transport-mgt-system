const express = require('express');

const appRouter = express.Router();
const userController = require('../controllers/userController');
const transportController = require('../controllers/transportController');

appRouter.route('/user/register')
  .post(userController.registerUser);

appRouter.route('/user/login')
  .post(userController.loginUser);

appRouter.route('/user/logout')
  .get(userController.logoutUser);
  


appRouter.route('/byid/:id')
  .get(userController.getUserById);

appRouter.route('/byusername/:username')
  .get(userController.getUserByName);

appRouter.route('/transport/book')
  .post(transportController.transportBookingsSubmit);

appRouter.route('/transport/:userid')
  .get(transportController.getTransportBookingList);


module.exports = appRouter;
