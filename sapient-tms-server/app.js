const express = require('express');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const cors = require('cors');
const rp = require('request-promise');

const userRouter = require('./src/routers/router');
const mlController = require('./src/controllers/mlController');

const app = express();
app.use(helmet());
app.use(cors());

//Body Parser middleware
app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());


const port = 5000;

app.use('/api/ml/:userid', (req, res) => {
  try {
    const options = {
      method: 'POST', 
      uri: 'http://15.206.72.134:6000/predict',
      body: req.body,
      json: true
  };

  return rp(options)
      .then((mlResponse) => {
        mlController(req.params.userid, mlResponse).then((dbResponse) => {
          res.set('Content-Type', 'application/json');
        res.status(201).send(dbResponse);
        });
        
      }).catch(err => {
        res.status(500).send({ statusCode: err.statusCode, msg: err.error.msg });
    })
  } catch (error) {
    next(error);
  }

})

app.use('/api', userRouter);

app.use('/', (req, res) => {
  res.send('Sapient TMS server OK!!!');
})

app.use((error, req, res, next) => {
  if (error) res.status(500).send({ statusCode: error.statusCode, msg: error.error.msg });
  next();
});

app.use((req, res) => {
  res.status(404).send('NOT Found.');
});

require('./src/db/dbConnect');

app.listen(port, () => {
  console.log('Sapient TMS server listening at port- ', port);
});
