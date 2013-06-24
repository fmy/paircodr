mongoose = require 'mongoose'
db = mongoose.connect 'mongodb://localhost/paircodr'

exports.Code = db.model 'Code', new mongoose.Schema
  owner: {type: String, default: "Anonymous"}
  title: {type: String, default: "hello_world.rb"}
  body: {type: String, default: ""}
  created: {type: Date, default: Date.now}

