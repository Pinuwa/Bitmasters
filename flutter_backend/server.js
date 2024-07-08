const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const multer = require('multer');

const app = express();
const port = 3000;

app.use(bodyParser.json({ limit: '50mb' }));
app.use(cors());

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'signup_db',
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err);
    return;
  }
  console.log('Connected to the MySQL database');
});

// Function to validate email format
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Signup endpoint
app.post('/signup', async (req, res) => {
  const { username, email, password, userType } = req.body;

  if (!username || !email || !password || !userType) {
    res.status(400).send('All fields are required');
    return;
  }

  if (!isValidEmail(email)) {
    res.status(400).send('Invalid email format');
    return;
  }

  try {
    // Check if the username or email already exists
    const checkQuery = 'SELECT * FROM users WHERE username = ? OR email = ?';
    connection.query(checkQuery, [username, email], async (err, results) => {
      if (err) {
        console.error('Error querying database:', err);
        res.status(500).send('Error querying database');
        return;
      }

      if (results.length > 0) {
        res.status(400).send('Username or email already exists');
        return;
      }

      const salt = await bcrypt.genSalt(10); // Generate a salt
      const hashedPassword = await bcrypt.hash(password, salt); // Hash the password with the salt

      const query = 'INSERT INTO users (username, email, password, user_type) VALUES (?, ?, ?, ?)';
      connection.query(query, [username, email, hashedPassword, userType], (err, results) => {
        if (err) {
          console.error('Error inserting data:', err);
          res.status(500).send('Error inserting data');
          return;
        }
        res.status(200).send('User registered successfully');
      });
    });
  } catch (err) {
    console.error('Error hashing password:', err);
    res.status(500).send('Error hashing password');
  }
});

// Signin endpoint
app.post('/signin', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    res.status(400).send('All fields are required');
    return;
  }

  const query = 'SELECT * FROM users WHERE username = ?';
  connection.query(query, [username], async (err, results) => {
    if (err) {
      console.error('Error querying database:', err);
      res.status(500).send('Error querying database');
      return;
    }

    if (results.length === 0) {
      res.status(401).send('Invalid username or password');
      return;
    }

    const user = results[0];

    try {
      const match = await bcrypt.compare(password, user.password); // Compare the hashed password
      if (match) {
        res.status(200).json({ userId: user.id, message: 'Login successful' }); // Send userId in response
      } else {
        res.status(401).send('Invalid username or password');
      }
    } catch (err) {
      console.error('Error comparing password:', err);
      res.status(500).send('Error comparing password');
    }
  });
});


//FORGET PASSWORD 

// Function to validate email format
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Function to send OTP email
async function sendOtpEmail(email, otp) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'rashinthawanigasekara@gmail.com',
      pass: 'nval yovp mbla bhvi'
    }
  });

  const mailOptions = {
    from: 'systemssllearning@gmail.com',
    to: email,
    subject: 'Your OTP Code',
    text: `Your RestPassword  OTP code is ${otp}`,
    html: `<p>Your OTP code is <b>${otp}</b></p>`
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('OTP email sent');
  } catch (error) {
    console.error('Error sending OTP email:', error);
  }
}

//SEND OPT CODE >>>>>>>>>>>>>>>>>>>

app.post('/send-otp', (req, res) => {
  const { email } = req.body;

  if (!isValidEmail(email)) {
    res.status(400).send('Invalid email format');
    return;
  }

  // Check if the email exists in the user table
  const checkEmailQuery = 'SELECT * FROM users WHERE email = ?';
  connection.query(checkEmailQuery, [email], (err, results) => {
    if (err) {
      console.error('Error checking email:', err);
      return res.status(500).send('Error checking email');
    }

    if (results.length === 0) {
      // Email not found
      res.status(404).send('You input email have no account');
    } else {
      // Email found, proceed to send OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const otpExpiration = Date.now() + 300000; // 5 minutes

      const updateQuery = 'UPDATE users SET reset_token = ?, reset_token_expiration = ? WHERE email = ?';
      connection.query(updateQuery, [otp, otpExpiration, email], async (err, result) => {
        if (err) {
          console.error('Error setting OTP:', err);
          return res.status(500).send('Error setting OTP');
        }

        try {
          await sendOtpEmail(email, otp);
          res.send('OTP sent');
        } catch (error) {
          console.error('Error sending OTP email:', error);
          res.status(500).send('Error sending OTP email');
        }
      });
    }
  });
});


// Endpoint to verify OTP and reset password
app.post('/verify-otp', async (req, res) => {
  const { email, otp, newPassword } = req.body;

  const query = 'SELECT * FROM users WHERE email = ?';
  connection.query(query, [email], async (err, results) => {
    if (err) {
      console.error('Error querying database:', err);
      res.status(500).send('Error querying database');
      return;
    }

    if (results.length === 0) {
      res.status(404).send('User not found');
      return;
    }

    const user = results[0];

    if (user.reset_token !== otp || user.reset_token_expiration < Date.now()) {
      res.status(400).send('Invalid or expired OTP');
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    const updateQuery = 'UPDATE users SET password = ?, reset_token = NULL, reset_token_expiration = NULL WHERE email = ?';
    connection.query(updateQuery, [hashedPassword, email], (updateErr) => {
      if (updateErr) {
        console.error('Error updating password:', updateErr);
        res.status(500).send('Error updating password');
        return;
      }

      res.send('Password reset successful');
    });
  });
});





//SSL page LETTERS GET TO INTERFACE

// Endpoint to get a specific letter by ID
app.get('/letter/:id', (req, res) => {
  const id = req.params.id;
  connection.query('SELECT * FROM letters WHERE id = ?', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const letter = results[0];
      res.json({
        id: letter.id,
        letter: letter.letter,
        image: letter.image.toString('base64')  // Convert image to base64
      });
    } else {
      res.status(404).send('Letter not found');
    }
  });
});

// Endpoint to get the next letter by ID
app.get('/letter/next/:id', (req, res) => {
  const id = parseInt(req.params.id);
  connection.query('SELECT * FROM letters WHERE id > ? ORDER BY id ASC LIMIT 1', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const letter = results[0];
      res.json({
        id: letter.id,
        letter: letter.letter,
        image: letter.image.toString('base64')  // Convert image to base64
      });
    } else {
      res.status(404).send('No next letter');
    }
  });
});

// Endpoint to get the previous letter by ID
app.get('/letter/prev/:id', (req, res) => {
  const id = parseInt(req.params.id);
  connection.query('SELECT * FROM letters WHERE id < ? ORDER BY id DESC LIMIT 1', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const letter = results[0];
      res.json({
        id: letter.id,
        letter: letter.letter,
        image: letter.image.toString('base64')  // Convert image to base64
      });
    } else {
      res.status(404).send('No previous letter');
    }
  });
});

// Fetch a specific word by ID
app.get('/word/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM words WHERE id = ?';
  connection.query(query, [id], (err, results) => {
    if (err) {
      console.error('Error fetching word:', err);
      res.status(500).send('Error fetching word');
      return;
    }
    if (results.length === 0) {
      res.status(404).send('Word not found');
      return;
    }
    const word = results[0];
    res.status(200).json({
      id: word.id,
      word: word.word,
      image: word.image.toString('base64'),
      
    });
  });
});

// Fetch the next word
app.get('/word/next/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM words WHERE id > ? ORDER BY id ASC LIMIT 1';
  connection.query(query, [id], (err, results) => {
    if (err) {
      console.error('Error fetching next word:', err);
      res.status(500).send('Error fetching next word');
      return;
    }
    if (results.length === 0) {
      res.status(404).send('No more words');
      return;
    }
    const word = results[0];
    res.status(200).json({
      id: word.id,
      word: word.word,
      image: word.image.toString('base64'),
      
    });
  });
});

// Fetch the previous word
app.get('/word/prev/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM words WHERE id < ? ORDER BY id DESC LIMIT 1';
  connection.query(query, [id], (err, results) => {
    if (err) {
      console.error('Error fetching previous word:', err);
      res.status(500).send('Error fetching previous word');
      return;
    }
    if (results.length === 0) {
      res.status(404).send('No more words');
      return;
    }
    const word = results[0];
    res.status(200).json({
      id: word.id,
      word: word.word,
      image: word.image.toString('base64'),
     
    });
  });
});



// LOAD NUMBERPAGE |||||||||||||||||||
app.get('/number/:id', (req, res) => {
  const id = req.params.id;
  const query = 'SELECT * FROM numbers WHERE id = ?';
  
  connection.query(query, [id], (err, result) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      if (result.length > 0) {
        const numberData = result[0];
        numberData.image = numberData.image.toString('base64');
        res.json(numberData);
      } else {
        res.status(404).json({ error: 'Number not found' });
      }
    }
  });
});

app.get('/number/next/:id', (req, res) => {
  const id = req.params.id;
  const query = 'SELECT * FROM numbers WHERE id > ? ORDER BY id ASC LIMIT 1';
  
  connection.query(query, [id], (err, result) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      if (result.length > 0) {
        const numberData = result[0];
        numberData.image = numberData.image.toString('base64');
        res.json(numberData);
      } else {
        res.status(404).json({ error: 'No next number' });
      }
    }
  });
});

app.get('/number/prev/:id', (req, res) => {
  const id = req.params.id;
  const query = 'SELECT * FROM numbers WHERE id < ? ORDER BY id DESC LIMIT 1';
  
  connection.query(query, [id], (err, result) => {
    if (err) {
      res.status(500).json({ error: err });
    } else {
      if (result.length > 0) {
        const numberData = result[0];
        numberData.image = numberData.image.toString('base64');
        res.json(numberData);
      } else {
        res.status(404).json({ error: 'No previous number' });
      }
    }
  });
});






// Fetch 10 random questions
app.get('/random-questions', (req, res) => {
  const query = `
    SELECT q.id as question_id, q.question, q.image, q.option1, q.option2, q.option3, q.option4, q.correctAnswer
    FROM questions q
    ORDER BY RAND()
    LIMIT 10;
  `;

  connection.query(query, (err, results) => {
    if (err) {
      console.error('Error querying database:', err);
      res.status(500).send('Error querying database');
      return;
    }

    const questions = results.map(result => ({
      id: result.question_id,
      question: result.question,
      image: result.image.toString('base64'),
      options: [result.option1, result.option2, result.option3, result.option4],
      correctAnswer: result.correctAnswer
    }));

    res.status(200).json(questions);
  });
});

// Store user progress
app.post('/submit-quiz', (req, res) => {
  const { userId, marks } = req.body; // Retrieve userId and marks from request body
  const query = `
    INSERT INTO user_progress (user_id, marks, date)
    VALUES (?, ?, NOW());
  `;

  connection.query(query, [userId, marks], (err, results) => {
    if (err) {
      console.error('Error inserting into database:', err);
      res.status(500).send('Error inserting into database');
      return;
    }

    res.status(200).send('Quiz submitted successfully');
  });
});

// Fetch user progress
app.get('/user-progress/:userId', (req, res) => {
  const userId = req.params.userId; // Extract userId from request params
  const query = 'SELECT * FROM user_progress WHERE user_id = ? ORDER BY date DESC';
  
  // Execute the query with userId as parameter
  connection.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching user progress:', err);
      res.status(500).send('Error fetching user progress');
      return;
    }
    res.status(200).json(results); // Send back results as JSON
  });
});



//VOICE PAGE|||||||||||||

// Endpoint to get a specific voice by ID
app.get('/voice/:id', (req, res) => {
  const id = req.params.id;
  connection.query('SELECT * FROM voices WHERE id = ?', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const voice = results[0];
      res.json({
        id: voice.id,
        word: voice.word,
        video: voice.video.toString('base64'),  // Convert video to base64
        image: voice.image.toString('base64')   // Convert image to base64
      });
    } else {
      res.status(404).send('Voice not found');
    }
  });
});

// Endpoint to get the next voice by ID
app.get('/voice/next/:id', (req, res) => {
  const id = parseInt(req.params.id);
  connection.query('SELECT * FROM voices WHERE id > ? ORDER BY id ASC LIMIT 1', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const voice = results[0];
      res.json({
        id: voice.id,
        word: voice.word,
        video: voice.video.toString('base64'),  // Convert video to base64
        image: voice.image.toString('base64')   // Convert image to base64
      });
    } else {
      res.status(404).send('No next voice');
    }
  });
});

// Endpoint to get the previous voice by ID
app.get('/voice/prev/:id', (req, res) => {
  const id = parseInt(req.params.id);
  connection.query('SELECT * FROM voices WHERE id < ? ORDER BY id DESC LIMIT 1', [id], (error, results) => {
    if (error) throw error;
    if (results.length > 0) {
      const voice = results[0];
      res.json({
        id: voice.id,
        word: voice.word,
        video: voice.video.toString('base64'),  // Convert video to base64
        image: voice.image.toString('base64')   // Convert image to base64
      });
    } else {
      res.status(404).send('No previous voice');
    }
  });
});


// Endpoint to upload a voice clip
app.post('/uploadVoiceClip', (req, res) => {
  const { userId, voiceId, voiceClip } = req.body;

  if (!userId || !voiceId || !voiceClip) {
    return res.status(400).send('Missing userId, voiceId, or voiceClip in request body');
  }

  const query = 'INSERT INTO voiceclips (userid, voiceid, voiceclip, date) VALUES (?, ?, ?, NOW())';
  connection.query(query, [userId, voiceId, voiceClip], (err, result) => {
    if (err) {
      console.error('Error inserting voice clip into the database:', err);
      return res.status(500).send('Error inserting voice clip into the database');
    }
    res.status(200).send('Voice clip uploaded successfully');
  });
});





// UPDATE PROFILE ENDPOINT
app.put('/update-profile', async (req, res) => {
  const { userId, username, email, currentPassword, newPassword } = req.body;

  if (!userId || !username || !email || !currentPassword || !newPassword) {
    return res.status(400).send('All fields are required');
  }

  const query = 'SELECT * FROM users WHERE id = ?';
  connection.query(query, [userId], async (err, results) => {
    if (err) {
      console.error('Error querying database:', err);
      return res.status(500).send('Error querying database');
    }

    if (results.length === 0) {
      return res.status(404).send('User not found');
    }

    const user = results[0];

    try {
      const match = await bcrypt.compare(currentPassword, user.password);
      if (!match) {
        return res.status(401).send('Current password is incorrect');
      }

      const salt = await bcrypt.genSalt(10);
      const hashedNewPassword = await bcrypt.hash(newPassword, salt);

      const updateQuery = 'UPDATE users SET username = ?, email = ?, password = ? WHERE id = ?';
      connection.query(updateQuery, [username, email, hashedNewPassword, userId], (updateErr) => {
        if (updateErr) {
          console.error('Error updating profile:', updateErr);
          return res.status(500).send('Error updating profile');
        }
        res.status(200).send('Profile updated successfully');
      });
    } catch (err) {
      console.error('Error updating profile:', err);
      return res.status(500).send('Error updating profile');
    }
  });
});

//PROGRESS VOICE PAGE


app.get('/user-voiceclips/:userId', (req, res) => {
  const userId = req.params.userId;
  const query = `
    SELECT vc.*, v.word 
    FROM voiceclips vc 
    JOIN voices v ON vc.voiceid = v.id 
    WHERE vc.userid = ?
  `;
  
  connection.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Error fetching voice clips: ', err);
      res.status(500).send('Error fetching voice clips');
    } else {
      res.json(results);
    }
  });
});




app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
