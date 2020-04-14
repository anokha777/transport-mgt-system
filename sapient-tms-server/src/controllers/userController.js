const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const config = require('../config/config');

const UserModel = require('../models/UserModel');
// const UserModel = mongoose.model('user');

const userController = {

  registerUser: (req, res, next) => {
    const saltRounds = 10;
    try {
      UserModel.find({ username: req.body.username.trim() })
        .exec().then((user) => {
          if (user.length > 0) {
            res.status(409).send({ msg: 'User name already taken, Please try with other.' });
          } else {
            bcrypt.hash(req.body.password.trim(), saltRounds, function (err, hash) {
              
              UserModel.create({
                name: req.body.name,
                mobileNum: req.body.mobileNum,
                username: req.body.username,
                password: hash,
                role: req.body.role,
                address: req.body.address
              }).then(response => {
                  res.set('Content-Type', 'application/json');
                  res.status(200).send({
                    id: response._id,
                    name: response.name,
                    mobileNum: response.mobileNum,
                    username: response.username,
                    role: response.role,
                    createdAt: response.createdAt
                  });
              })
            });
          }
        });
    } catch (error) {
      res.status(500).send({ msg: 'Error in registration.' });
    }
  },

  logoutUser: (req, res, next) => {
    try {
      res.set('Content-Type', 'application/json');
      res.status(201).send({
        token: null,
        id: null,
        message: 'You have logged out successfully!!!'
      });
    } catch (error) {
      res.status(500).send({ msg: 'Error in logout' });
    }
  },

  loginUser: (req, res, next) => {
    UserModel.find({ username: req.body.username.trim() })
      .exec()
      .then((user) => {
        if (user.length < 1) {
          res.status(401).json({
            msg: 'Auth failed',
          });
        } else {
          bcrypt.compare(req.body.password.trim(), user[0].password, function (err, compareRes) {
            if (compareRes === true) {
              /* eslint no-underscore-dangle: ["error", { "allow": ["_id"] }] */
              const token = jwt.sign({ sub: user[0]._id, username: user[0].username }, config.secret, { expiresIn: '1h' });
              return res.status(200).json({
                msg: 'Auth successful',
                token,
                id: user[0]._id,
                username: user[0].username,
                name: user[0].name,
                mobileNum: user[0].mobileNum,
                role: user[0].role,
                address: user[0].address,
              });
            } else {
              res.status(401).json({
                msg: 'Auth failed',
              });
            }
          });
        }
      })
      .catch((error) => {
        res.status(401).send({
          msg: 'Auth failed',
        });
      });
  },

  getUserById: (req, res, next) => {
    UserModel.findById({ _id: req.params.id }, (err, user) => {
      if (err) {
        throw err;
      } else {
        return res.status(200).json({
          id: user._id,
          name: user.name,
          username: user.username,
          mobileNum: user.mobileNum,
          role: user.role,
          createdAt: user.createdAt,
        });
      }
    });
  },

  getUserByName: (req, res, next) => {
    UserModel.find({ username: req.params.username }, (err, user) => {
      if (err) {
        throw err;
      } else {
        return res.status(200).json({
          id: user[0]._id,
          name: user[0].name,
          username: user[0].username,
          role: user[0].role,
          createdAt: user[0].createdAt,
        });
      }
    });
  }

}

module.exports = userController;
