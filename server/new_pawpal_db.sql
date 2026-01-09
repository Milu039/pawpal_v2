-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 09, 2026 at 06:16 PM
-- Server version: 10.3.39-MariaDB-log-cll-lve
-- PHP Version: 8.1.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pawpal_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adoptions`
--

CREATE TABLE `tbl_adoptions` (
  `pet_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `adoption_reason` varchar(255) NOT NULL,
  `adopted_status` tinyint(1) NOT NULL,
  `adopted_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adoptions`
--

INSERT INTO `tbl_adoptions` (`pet_id`, `user_id`, `adoption_reason`, `adopted_status`, `adopted_at`) VALUES
(10, 1, 'aaa', 1, '2026-01-05 00:30:41'),
(8, 2, 'dadad', 1, '2026-01-05 23:55:46');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_donations`
--

CREATE TABLE `tbl_donations` (
  `user_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `category` varchar(255) NOT NULL,
  `donate` text NOT NULL,
  `reg_date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_donations`
--

INSERT INTO `tbl_donations` (`user_id`, `pet_id`, `category`, `donate`, `reg_date`) VALUES
(3, 11, 'Food', 'meat', '2026-01-09 18:05:15');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pets`
--

CREATE TABLE `tbl_pets` (
  `pet_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `pet_type` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `image_paths` text DEFAULT NULL,
  `lat` varchar(50) NOT NULL,
  `lng` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pets`
--

INSERT INTO `tbl_pets` (`pet_id`, `user_id`, `pet_name`, `pet_type`, `category`, `description`, `image_paths`, `lat`, `lng`, `created_at`) VALUES
(7, 1, 'Grenn', 'Other', 'Adoption', 'a Grenn for adopt', 'pet_7_0.png,pet_7_1.png', '6.448535', '100.5096233', '2025-12-06 11:26:41'),
(8, 1, 'Cat', 'Cat', 'Adoption', 'cat for adopt', 'pet_8_0.png,pet_8_1.png,pet_8_2.png', '6.448535', '100.5096233', '2025-12-06 13:12:46'),
(10, 2, 'mike', 'Dog', 'Adoption', 'Dog for adopt', '', '6.448535', '100.5096233', '2026-01-05 13:12:46'),
(11, 1, 'sda', 'Rabbit', 'Donation Request', 'pls donate', 'pet_11_0.png', '6.4662733', '100.50516', '2026-01-05 23:23:50'),
(12, 1, 'sdasd', 'Other', 'Help/Rescue', 'dasdasdasd', 'pet_12_0.png,pet_12_1.png', '6.4662733', '100.50516', '2026-01-05 23:24:14'),
(13, 1, 'asdasdad', 'Other', 'Other', 'eqwewqeqwe', 'pet_13_0.png,pet_13_1.png', '6.4662733', '100.50516', '2026-01-05 23:24:39');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `profile_image` text DEFAULT NULL,
  `reg_date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `name`, `email`, `password`, `phone`, `profile_image`, `reg_date`) VALUES
(1, 'limjc', 'lim@gmail.com', 'c0fb631ea9173ef3401baffd1d57398922010185', '1234567890', 'user_profile_1.png', '2025-12-04 19:06:39'),
(2, 'john', 'john@gmail.com', 'a570b30f3e99f4a11e2d07fcd273b946c1f8b014', '11111111', NULL, '2026-01-05 00:03:12'),
(3, 'TehOAis', 'TehO@gmail.com', '3aa41e5702bb4511a95f7df4c892cb0f72addf8d', '012345666', 'user_profile_3.png', '2026-01-06 02:28:54'),
(4, 'niu', 'niu@gmail.com', 'c3100ac42f01539e067bdbc849649b27dc9d9e70', '6513213', 'user_profile_4.png', '2026-01-06 02:43:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_adoptions`
--
ALTER TABLE `tbl_adoptions`
  ADD KEY `pet_id` (`pet_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_donations`
--
ALTER TABLE `tbl_donations`
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pet_id` (`pet_id`);

--
-- Indexes for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  ADD PRIMARY KEY (`pet_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  MODIFY `pet_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_adoptions`
--
ALTER TABLE `tbl_adoptions`
  ADD CONSTRAINT `tbl_adoptions_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pets` (`pet_id`),
  ADD CONSTRAINT `tbl_adoptions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`);

--
-- Constraints for table `tbl_donations`
--
ALTER TABLE `tbl_donations`
  ADD CONSTRAINT `tbl_donations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`),
  ADD CONSTRAINT `tbl_donations_ibfk_2` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pets` (`pet_id`);

--
-- Constraints for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  ADD CONSTRAINT `tbl_pets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tbl_users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
