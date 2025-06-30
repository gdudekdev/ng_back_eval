const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const bcrypt = require("bcrypt");
const jwtUtils = require("jsonwebtoken");
const interceptor = require("./middleware/jwt-interceptor");

const app = express();

const connection = mysql.createConnection({
  host: "localhost",
  user: "root",
  database: "ng_eval",
});

connection.connect((err) => {
  if (err) {
    console.error("Erreur de connexion à la base de données :", err);
    return;
  }
  console.log("Connecté à la base de données MySQL");
});

app.use(cors());

app.use(express.json());

app.get("/", (requete, resultat) => {
  resultat.send("<h1>C'est une API il y a rien a voir ici</h1>");
});

app.get("/rides/list", (requete, resultat) => {
  connection.query(
    "SELECT r.*, accounts_fullname FROM rides r JOIN accounts a ON r.accounts_id= a.accounts_id ORDER BY rides_departure_time DESC",
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }

      return resultat.json(lignes);
    }
  );
});
app.get("/rides/me", interceptor, (requete, resultat) => {
  console.log(requete.user);
  connection.query(
    "SELECT * FROM rides r WHERE r.accounts_id = ? ORDER BY rides_departure_time DESC",
    [requete.user.id],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }

      return resultat.json(lignes);
    }
  );
});
app.get("/bookings/me", interceptor, (requete, resultat) => {
  connection.query(
    "SELECT * FROM bookings b JOIN rides r ON b.rides_id= r.rides_id WHERE r.accounts_id  = ? OR b.bookings_sender_id = ?  ORDER BY r.rides_departure_time DESC",
    [requete.user.id, requete.user.id],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }
      const sent = [];
      const received = [];

      lignes.forEach((ligne) => {
        if (ligne.bookings_sender_id === requete.user.id) {
          sent.push(ligne);
        }
        if (ligne.accounts_id === requete.user.id) {
          received.push(ligne);
        }
      });

      return resultat.json({ sent, received });
    }
  );
});
app.put("/bookings/me", interceptor, (requete, resultat) => {
  const bookings = requete.body;
  console.log(bookings);
  if (
    bookings.bookings_id == null ||
    bookings.bookings_status == null ||
    !["accepted", "refused"].includes(bookings.bookings_status)
  ) {
    console.log("error is there");
    return resultat.sendStatus(400);
  }
  connection.query(
    "SELECT * FROM bookings WHERE bookings_id = ? ",
    [bookings.bookings_id],
    (err, lignes) => {
      if (err) {
        console.log(err);
        return resultat.sendStatus(500);
      }
      if (!lignes[0]) {
        return resultat.sendStatus(400);
      }
      if (lignes[0]["bookings_sender_id"] != requete.user.id) {
        return resultat.sendStatus(403);
      }
    }
  );
  connection.query(
    "UPDATE bookings SET bookings_status = ? WHERE bookings_id = ?",
    [bookings.bookings_status, bookings.bookings_id],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }
      resultat.status(201).json(bookings);
    }
  );
});
app.post("/bookings", interceptor, (requete, resultat) => {
  const bookings = requete.body;
  if (bookings.rides_id == null) {
    return resultat.sendStatus(400);
  }
  connection.query(
    "INSERT INTO bookings (rides_id,bookings_sender_id) VALUES (?, ?)",
    [bookings.rides_id, requete.user.id],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }

      resultat.status(201).json(bookings);
    }
  );
});
app.get("/rides/:id", (requete, resultat) => {
  connection.query(
    "SELECT * FROM rides WHERE rides_id = ?",
    [requete.params.id],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }
      if (lignes.length == 0) {
        return resultat.sendStatus(404);
      }

      return resultat.json(lignes[0]);
    }
  );
});

app.put("/rides/:id", interceptor, (requete, resultat) => {
  const rides = requete.body;
  const nowPlus24h = Date.now() + 24 * 60 * 60 * 1000;
  if (
    rides.rides_departure == null ||
    rides.rides_destination == null ||
    rides.rides_seats == null ||
    rides.rides_departure_time == null ||
    new Date(rides.rides_departure_time).getTime() < nowPlus24h ||
    rides.rides_destination.length > 40 ||
    rides.rides_departure.length > 40 ||
    rides.rides_seats < 1 ||
    rides.rides_departure == "" ||
    rides.rides_destination == ""
  ) {
    return resultat.sendStatus(400);
  }

  connection.query(
    "SELECT * FROM rides WHERE rides_id = ? AND accounts_id = ?",
    [requete.params.id, requete.user.id],
    (err, lignes) => {
      if (lignes.length !== 1) {
        console.log(lignes);
        return resultat.sendStatus(409);
      }

      connection.query(
        "UPDATE rides SET rides_departure = ?, rides_destination = ? , rides_seats = ? , rides_departure_time = ? WHERE rides_id = ?",
        [
          rides.rides_departure,
          rides.rides_destination,
          rides.rides_seats,
          rides.rides_departure_time,
          rides.rides_id,
        ],
        (err, lignes) => {
          if (err) {
            console.error(err);
            return resultat.sendStatus(500);
          }
          return resultat.status(200).json(rides);
        }
      );
    }
  );
});

app.post("/rides", interceptor, (requete, resultat) => {
  const rides = requete.body;
  const nowPlus24h = Date.now() + 24 * 60 * 60 * 1000;
  if (
    rides.rides_departure == null ||
    rides.rides_destination == null ||
    rides.rides_seats == null ||
    rides.rides_departure_time == null ||
    new Date(rides.rides_departure_time).getTime() < nowPlus24h ||
    rides.rides_destination.length > 40 ||
    rides.rides_departure.length > 40 ||
    rides.rides_seats < 1 ||
    rides.rides_departure == "" ||
    rides.rides_destination == ""
  ) {
    return resultat.sendStatus(400);
  }
  connection.query(
    "INSERT INTO rides (rides_departure, rides_destination, rides_seats, rides_departure_time, accounts_id) VALUES (?, ?, ?, ?, ?)",
    [
      rides.rides_departure,
      rides.rides_destination,
      rides.rides_seats,
      rides.rides_departure_time,
      requete.user.id,
    ],
    (err, lignes) => {
      if (err) {
        console.error(err);
        return resultat.sendStatus(500);
      }

      resultat.status(201).json(rides);
    }
  );
});

app.delete("/rides/:id", interceptor, (requete, resultat) => {
  connection.query(
    "SELECT * FROM rides WHERE rides_id = ?",
    [requete.params.id],
    (erreur, lignes) => {
      if (erreur) {
        console.error(err);
        return resultat.sendStatus(500);
      }

      if (lignes.length == 0) {
        return resultat.sendStatus(404);
      }

      const estProprietaire =
        requete.user.role == "user" && requete.user.id == lignes[0].accounts_id;

      if (!estProprietaire && requete.user.role != "admin") {
        return resultat.sendStatus(403);
      }

      connection.query(
        "DELETE FROM rides WHERE rides_id = ?",
        [requete.params.id],
        (erreur, lignes) => {
          if (erreur) {
            console.error(err);
            return resultat.sendStatus(500);
          }

          return resultat.sendStatus(204);
        }
      );
    }
  );
});

app.post("/inscription", (requete, resultat) => {
  const accounts = requete.body;

  const passwordHash = bcrypt.hashSync(accounts.accounts_password, 10);

  connection.query(
    "INSERT INTO accounts (accounts_email, accounts_password) VALUES (? , ?)",
    [accounts.accounts_email, passwordHash],
    (err, retour) => {
      if (err && err.code == "ER_DUP_ENTRY") {
        return resultat.sendStatus(409); //conflict
      }

      if (err) {
        console.error(err);
        return resultat.sendStatus(500); //internal server error
      }

      accounts.accounts_id = retour.insertId;
      resultat.json(accounts);
    }
  );
});

app.post("/connexion", (requete, resultat) => {
  connection.query(
    `SELECT u.accounts_id, u.accounts_email, u.accounts_password, r.roles_name 
      FROM accounts u 
      JOIN roles r ON u.roles_id = r.roles_id 
      WHERE accounts_email = ?`,
    [requete.body.accounts_email],
    (erreur, lignes) => {
      if (erreur) {
        console.error(erreur);
        return resultat.sendStatus(500); //internal server error
      }

      console.log(lignes);

      //si l'email est inexistant
      if (lignes.length === 0) {
        return resultat.sendStatus(401);
      }

      const motDePasseFormulaire = requete.body.accounts_password;
      const motDePasseHashBaseDeDonnees = lignes[0].accounts_password;

      const compatible = bcrypt.compareSync(
        motDePasseFormulaire,
        motDePasseHashBaseDeDonnees
      );

      if (!compatible) {
        return resultat.sendStatus(401);
      }

      return resultat.send(
        jwtUtils.sign(
          {
            sub: requete.body.accounts_email,
            role: lignes[0].roles_name,
            id: lignes[0].accounts_id,
          },
          "azerty123"
        )
      );
    }
  );
});

app.listen(5000, () => console.log("Le serveur écoute sur le port 5000 !!"));
