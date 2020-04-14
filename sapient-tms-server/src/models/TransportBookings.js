const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const TransportBookingsSchema = new Schema({
  userFor: {type: Schema.Types.ObjectId, ref: 'user'},
  requestedDate: { type: String, require: true },
  requestedTime: { type: String, required: true },
  createDatetime: { type: Date, default: Date.now() },
});

module.exports = mongoose.model('transportBookings', TransportBookingsSchema);
