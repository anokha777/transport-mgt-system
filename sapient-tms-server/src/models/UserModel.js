const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UserSchema = new Schema({
  name: { type: String, require: true },
  mobileNum: { type: String, require: true },
  username: { type: String, required : true },
  password: { type: String, required : true },
  role: { type: String, required: true },
  address: { type: String, required: false },
  createdAt: { type: Date, default: Date.now() },
});

// UserSchema.index({ location: '2dsphere' });
    
module.exports = mongoose.model('user', UserSchema);
