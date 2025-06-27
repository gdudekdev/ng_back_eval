-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 27 juin 2025 à 10:01
-- Version du serveur : 9.1.0
-- Version de PHP : 8.2.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `ng_eval`
--

-- --------------------------------------------------------

--
-- Structure de la table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
CREATE TABLE IF NOT EXISTS `accounts` (
  `accounts_id` int NOT NULL AUTO_INCREMENT,
  `accounts_fullname` varchar(250) NOT NULL,
  `accounts_email` varchar(250) NOT NULL,
  `accounts_password` varchar(250) NOT NULL,
  `roles_id` int NOT NULL DEFAULT '2',
  PRIMARY KEY (`accounts_id`),
  UNIQUE KEY `accounts_email` (`accounts_email`),
  KEY `FK_accounts_roles` (`roles_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `accounts`
--

INSERT INTO `accounts` (`accounts_id`, `accounts_fullname`, `accounts_email`, `accounts_password`, `roles_id`) VALUES
(1, 'John', 'a@a', '$2b$10$hC9lZRFmIAFdDWkWfJMGvuasMpsAqSLf5.UAR3NQXh/P5.5i3F46W', 2);

-- --------------------------------------------------------

--
-- Structure de la table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE IF NOT EXISTS `bookings` (
  `bookings_id` int NOT NULL AUTO_INCREMENT,
  `bookings_status` varchar(250) NOT NULL,
  `rides_id` int NOT NULL,
  `bookings_sender_id` int NOT NULL,
  PRIMARY KEY (`bookings_id`),
  KEY `FK_bookings_accounts` (`bookings_sender_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `bookings`
--

INSERT INTO `bookings` (`bookings_id`, `bookings_status`, `rides_id`, `bookings_sender_id`) VALUES
(1, 'pending', 4, 1),
(2, 'pending', 5, 1);

-- --------------------------------------------------------

--
-- Structure de la table `brands`
--

DROP TABLE IF EXISTS `brands`;
CREATE TABLE IF NOT EXISTS `brands` (
  `brands_id` int NOT NULL AUTO_INCREMENT,
  `brands_name` varchar(250) NOT NULL,
  PRIMARY KEY (`brands_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `colors`
--

DROP TABLE IF EXISTS `colors`;
CREATE TABLE IF NOT EXISTS `colors` (
  `colors_id` int NOT NULL AUTO_INCREMENT,
  `colors_name` varchar(250) NOT NULL,
  `colors_hexa` varchar(250) NOT NULL,
  PRIMARY KEY (`colors_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `engines`
--

DROP TABLE IF EXISTS `engines`;
CREATE TABLE IF NOT EXISTS `engines` (
  `engines_id` int NOT NULL AUTO_INCREMENT,
  `engines_name` varchar(250) NOT NULL,
  PRIMARY KEY (`engines_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `models`
--

DROP TABLE IF EXISTS `models`;
CREATE TABLE IF NOT EXISTS `models` (
  `models_id` int NOT NULL AUTO_INCREMENT,
  `models_name` varchar(250) NOT NULL,
  `brands_id` int NOT NULL,
  PRIMARY KEY (`models_id`),
  KEY `FK_models_brands` (`brands_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rides`
--

DROP TABLE IF EXISTS `rides`;
CREATE TABLE IF NOT EXISTS `rides` (
  `rides_id` int NOT NULL AUTO_INCREMENT,
  `rides_departure` varchar(250) NOT NULL,
  `rides_destination` varchar(250) NOT NULL,
  `rides_seats` int NOT NULL,
  `rides_departure_time` varchar(255) NOT NULL,
  `vehicules_id` int DEFAULT '0',
  `accounts_id` int NOT NULL,
  PRIMARY KEY (`rides_id`),
  KEY `FK_rides_accounts` (`accounts_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `rides`
--

INSERT INTO `rides` (`rides_id`, `rides_departure`, `rides_destination`, `rides_seats`, `rides_departure_time`, `vehicules_id`, `accounts_id`) VALUES
(4, '1, Rue de la Paix, Paris', '2, Rue de la Paix, Parisa', 2, '2025-07-02T08:30', 0, 1),
(5, '2 Rue de la paix Paris', '3  Rue de la paix Paris', 4, '2025-07-03T08:00', 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `roles_id` int NOT NULL AUTO_INCREMENT,
  `roles_name` varchar(250) NOT NULL,
  PRIMARY KEY (`roles_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`roles_id`, `roles_name`) VALUES
(1, 'admin'),
(2, 'user');

-- --------------------------------------------------------

--
-- Structure de la table `vehicules`
--

DROP TABLE IF EXISTS `vehicules`;
CREATE TABLE IF NOT EXISTS `vehicules` (
  `vehicules_id` int NOT NULL AUTO_INCREMENT,
  `models_id` int NOT NULL,
  `colors_id` int NOT NULL,
  `engines_id` int NOT NULL,
  `accounts_id` int NOT NULL,
  PRIMARY KEY (`vehicules_id`),
  KEY `FK_vehicules_accounts` (`accounts_id`),
  KEY `FK_vehicules_engines` (`engines_id`),
  KEY `FK_vehicules_models` (`models_id`),
  KEY `FK_vehiculles_colors` (`colors_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `accounts`
--
ALTER TABLE `accounts`
  ADD CONSTRAINT `FK_accounts_roles` FOREIGN KEY (`roles_id`) REFERENCES `roles` (`roles_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `FK_bookings_accounts` FOREIGN KEY (`bookings_sender_id`) REFERENCES `accounts` (`accounts_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `models`
--
ALTER TABLE `models`
  ADD CONSTRAINT `FK_models_brands` FOREIGN KEY (`brands_id`) REFERENCES `brands` (`brands_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `rides`
--
ALTER TABLE `rides`
  ADD CONSTRAINT `FK_rides_accounts` FOREIGN KEY (`accounts_id`) REFERENCES `accounts` (`accounts_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Contraintes pour la table `vehicules`
--
ALTER TABLE `vehicules`
  ADD CONSTRAINT `FK_vehicules_accounts` FOREIGN KEY (`accounts_id`) REFERENCES `accounts` (`accounts_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_vehicules_engines` FOREIGN KEY (`engines_id`) REFERENCES `engines` (`engines_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_vehicules_models` FOREIGN KEY (`models_id`) REFERENCES `models` (`models_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `FK_vehiculles_colors` FOREIGN KEY (`colors_id`) REFERENCES `colors` (`colors_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
