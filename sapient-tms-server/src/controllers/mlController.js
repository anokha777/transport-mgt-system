const mongoose = require('mongoose');

const ObjectId = require('mongoose').Types.ObjectId;
const config = require('../config/config');

const UserModel = require('../models/UserModel');

require('../models/TransportBookings');
const TransportBookingsModel= mongoose.model('transportBookings');

const mlController = (userFor, reqObject) => {
  return new Promise((resolve, reject) => {
    if(reqObject.entent === 'create') {
      try {
        TransportBookingsModel.create({
          userFor: userFor,
          requestedDate: reqObject.date,
          requestedTime: reqObject.time
        }).then((response) => {
          resolve({
            entent: 'create',
            statusCode: 200,
            transportBookingList: [response],
            msg: "We have booked your transport successfully."
          });
        })
      } catch (error) {
        reject(error)
      }
    } else if (reqObject.entent === 'show') {
      TransportBookingsModel.find({ userFor: userFor }, (err, transportBookingList) => {
        if (err) {
          reject(err);
        } else if(transportBookingList.length < 1) {
          resolve({
            entent: 'show',
            statusCode: 200,
            transportBookingList: [],
            msg: "We did not find any transport booking history for you."
          });
        } else {
          resolve({
            entent: 'show',
            statusCode: 200,
            userFor: userFor,
            transportBookingList,
            msg: "Here is your transport booking history."
          });
        }
      })
    } else if (reqObject.entent === 'home') {
      resolve({
        entent: 'home',
        statusCode: 200,
        msg: "Here is your home screen."
      });
    } else {
      resolve({
        entent: 'undefined',
        statusCode: 200,
        msg: "I did not understand, I can help you in booking transport. Thankyou."
      });
    }
  });
};


module.exports = mlController;
