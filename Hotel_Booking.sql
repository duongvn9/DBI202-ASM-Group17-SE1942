USE [master]
IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'Hotel_Booking')
drop database [Hotel_Booking]
GO
/****** Object:  Database [Hotel_Booking]    Script Date: 04/03/2025 23:07:00 PM ******/
CREATE DATABASE [Hotel_Booking]
GO
USE [FUH_COMPANY2]