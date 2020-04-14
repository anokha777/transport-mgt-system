const mongoose = require('mongoose');
const ObjectId = require('mongoose').Types.ObjectId;
const config = require('../config/config');

const UserModel = require('../models/UserModel');
// const TransportBookingsModel = require('../models/TransportBookings');

require('../models/TransportBookings');
const TransportBookingsModel= mongoose.model('transportBookings');

const transportController = {
  transportBookingsSubmit: (req, res, next) => {
    try {
      TransportBookingsModel.create({
        userFor: req.body.userFor,
        requestedDate: req.body.requestedDate,
        requestedTime: req.body.requestedTime
      }).then((response) => {
        res.set('Content-Type', 'application/json');
        res.status(200).send({ response });
      })
    } catch (error) {
      res.status(500).send({ msg: 'Error in transportBookingsSubmit.' });
    }
  },
 
  getTransportBookingList: (req, res, next) => {
    TransportBookingsModel.find({ userFor: req.params.userid }, (err, transportBookingList) => {
      if (err) {
        throw err;
      } else if(transportBookingList.length < 1) {
        return res.status(200).json([]);
      } else {
        return res.status(200).json([{
          userFor: req.params.userid,
          transportBookingList
        }
      ]);
      }
    })
  }
  
}

module.exports = transportController;
