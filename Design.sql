-- Tạo bảng CUSTOMER
CREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL CHECK (Name NOT LIKE '%[^A-Za-z ]%'), 
    DOB DATE NOT NULL CHECK (DOB <= GETDATE()),
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber CHAR(10) NOT NULL UNIQUE CHECK (PhoneNumber NOT LIKE '%[^0-9]%') 
);

-- Tạo bảng ROOM
CREATE TABLE ROOM (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomType VARCHAR(20) NOT NULL CHECK (RoomType IN ('Single', 'Double', 'Suite', 'Deluxe')),
    RoomPrice DECIMAL(10,2) NOT NULL CHECK (RoomPrice > 0),
    RoomStatus VARCHAR(20) NOT NULL CHECK (RoomStatus IN ('Available', 'Occupied', 'Maintenance'))
);

-- Tạo bảng BOOKING
CREATE TABLE BOOKING (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    RoomID INT NOT NULL,
    BookingDate DATE NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    BookingStatus VARCHAR(20) NOT NULL CHECK (BookingStatus IN ('Pending', 'Confirmed', 'Checked-in', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE
);

-- Tạo bảng PAYMENT
CREATE TABLE PAYMENT (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentMethod VARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Bank Transfer')),
    PaymentStatus VARCHAR(20) NOT NULL CHECK (PaymentStatus IN ('Paid', 'Pending', 'Failed')),
    FOREIGN KEY (BookingID) REFERENCES BOOKING(BookingID) ON DELETE CASCADE
);

-- Tạo bảng SERVICE
CREATE TABLE SERVICE (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    ServiceName VARCHAR(100) NOT NULL UNIQUE CHECK (ServiceName NOT LIKE '%[^A-Za-z ]%'),
    ServicePrice DECIMAL(10,2) NOT NULL CHECK (ServicePrice >= 0),
    ServiceDescription NVARCHAR(255) NULL
);

-- Tạo bảng STAFF
CREATE TABLE STAFF (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    StaffName VARCHAR(100) NOT NULL CHECK (StaffName NOT LIKE '%[^A-Za-z ]%'),
    StaffDepartment VARCHAR(50) NOT NULL CHECK (StaffDepartment IN ('Housekeeping', 'Reception', 'Maintenance', 'Catering')),
    ServiceID INT,
    FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID) ON DELETE SET NULL
);

-- Tạo bảng ROOM_SERVICE
CREATE TABLE ROOM_SERVICE (
    RoomID INT NOT NULL,
    ServiceID INT NOT NULL,
    PRIMARY KEY (RoomID, ServiceID),
    FOREIGN KEY (RoomID) REFERENCES ROOM(RoomID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID) ON DELETE CASCADE
);
