const mongoose = require('mongoose');
const config = require('../config/config');

const db = mongoose.connect(config.mongoURI, { useUnifiedTopology: true, useNewUrlParser: true, useCreateIndex: true  }, (error) => {
  if (error) {
    console.log('Sapient TMS db connection error- ', error);
    throw (error);
  } else {
    console.log('Sapient TMS db connected....');
  }
});

module.exports = db;
