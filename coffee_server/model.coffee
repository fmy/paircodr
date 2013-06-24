mongo_uri = process.env.MONGOHQ_URL || 'mongodb://localhost/paircodr'
mongoose = require 'mongoose'
db = mongoose.connect mongo_uri

exports.Code = db.model 'Code', new mongoose.Schema
  owner: {type: String, default: "Anonymous"}
  title: {type: String, default: "hello_world.rb"}
  body: {type: String, default: ""}
  created: {type: Date, default: Date.now}

