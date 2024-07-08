const crypto = require('crypto');

const randomBytes = crypto.randomBytes(32).toString('hex');
console.log('Random Bytes:', randomBytes);
