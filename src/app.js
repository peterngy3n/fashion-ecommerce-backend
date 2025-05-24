const express = require('express');
const app = express();


require('dotenv').config();
//require('./utils/cronJobs'); // Chạy cron job tự động

const helmet = require('helmet') 
const morgan = require('morgan')
const cookieParser = require('cookie-parser')
const cors = require('cors');

const routes = require('./routes/index')

const {errorHandler} = require('./middleware/error.middleware')

const compression = require('compression');

//Init middleware

app.use(express.json());
app.use(cookieParser());
app.use(morgan('dev'));
app.use(helmet());
app.use(compression());

app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE']
}));
//Handle routes
app.use('/api/v1', routes)
//Handle error
app.use(errorHandler);

module.exports = {app};