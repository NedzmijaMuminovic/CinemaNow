CREATE DATABASE IB200033
GO
USE IB200033

CREATE TABLE [User] (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Email VARCHAR(100),
    Username VARCHAR(50),
    PasswordSalt NVARCHAR(128),
    PasswordHash NVARCHAR(128),
    Image VARBINARY(MAX),
    ImageThumb VARBINARY(MAX)
);

CREATE TABLE Role (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE UserRole (
    UserID INT,
    RoleID INT,
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE,
    FOREIGN KEY (RoleID) REFERENCES Role(ID) ON DELETE CASCADE,
    PRIMARY KEY (UserID, RoleID)
);

CREATE TABLE Movie (
    ID INT PRIMARY KEY IDENTITY,
    Title VARCHAR(100),
    Duration INT,
    Synopsis VARCHAR(MAX),
    Image VARBINARY(MAX),
    ImageThumb VARBINARY(MAX)
);

CREATE TABLE Genre (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE MovieGenre (
    MovieID INT,
    GenreID INT,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
    FOREIGN KEY (GenreID) REFERENCES Genre(ID) ON DELETE CASCADE,
    PRIMARY KEY (MovieID, GenreID)
);

CREATE TABLE Actor (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Image VARBINARY(MAX),
    ImageThumb VARBINARY(MAX)
);

CREATE TABLE MovieActor (
    MovieID INT,
    ActorID INT,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
    FOREIGN KEY (ActorID) REFERENCES Actor(ID) ON DELETE CASCADE,
    PRIMARY KEY (MovieID, ActorID)
);

CREATE TABLE Hall (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE ViewMode (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(50)
);

CREATE TABLE Screening (
    ID INT PRIMARY KEY IDENTITY,
    MovieID INT,
	HallID INT,
	ViewModeID INT,
    Date DATE,
    Time TIME,
    Price DECIMAL(10,2),
    StateMachine VARCHAR(50),
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
	FOREIGN KEY (HallID) REFERENCES Hall(ID) ON DELETE CASCADE,
    FOREIGN KEY (ViewModeID) REFERENCES ViewMode(ID) ON DELETE CASCADE
);

CREATE TABLE PayPalPayment (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    Info VARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE
);

CREATE TABLE Seat (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(10),
    ScreeningID INT,
    IsReserved BIT,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE CASCADE
);

CREATE TABLE Reservation (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    ScreeningID INT,
    SeatID INT,
    Date DATE,
    NumberOfTickets INT,
    TotalPrice DECIMAL(10,2),
    Status VARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE NO ACTION,
	FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE NO ACTION,
	FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE NO ACTION
);

CREATE TABLE Purchase (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    ScreeningID INT,
    SeatID INT,
    Date DATE,
    NumberOfTickets INT,
    TotalPrice DECIMAL(10,2),
    Status VARCHAR(50),
    PayPalPaymentID INT,
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE NO ACTION,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE NO ACTION,
    FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE NO ACTION,
    FOREIGN KEY (PayPalPaymentID) REFERENCES PayPalPayment(ID) ON DELETE NO ACTION
);

CREATE TABLE Rating (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    MovieID INT,
    Value INT,
    Comment VARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE
);

INSERT INTO [User] (Name, Surname, Email, Username, PasswordSalt, PasswordHash, Image, ImageThumb)
VALUES 
('Emma', 'Johnson', 'emma.j@example.com', 'emma_j', 'abcdefg12345', '$2y$10$uFj8G3cSJazj5VpShYYGYODSQ8xVOlBghxOGU5iGBt7mXc/Q8qM12', NULL, NULL),
('Michael', 'Smith', 'michael.s@example.com', 'michael_s', 'qwerty12345', '$2y$10$jHWmzGdZdfA4oUGZ9Efjzuj8sGp0fV9YzKyZUB41VTH4v2QGw3L/q', NULL, NULL),
('Olivia', 'Williams', 'olivia.w@example.com', 'olivia_w', '1234567890', '$2y$10$zJGeJDEYIlyuk3vm.V6EyO0RFVdoXvXy5F/SJxXTntMP0JArz5SdC', NULL, NULL);

INSERT INTO Role (Name)
VALUES 
('User'),
('Admin');

INSERT INTO UserRole (UserID, RoleID)
VALUES 
(1, 1),
(2, 1),
(3, 2);

INSERT INTO Movie (Title, Duration, Synopsis, Image, ImageThumb)
VALUES 
('The Shawshank Redemption', 142, 'Two imprisoned men bond over a number of years...', NULL, NULL),
('The Godfather', 175, 'The aging patriarch of an organized crime dynasty...', NULL, NULL),
('The Dark Knight', 152, 'When the menace known as the Joker wreaks havoc...', NULL, NULL);

INSERT INTO Genre (Name)
VALUES 
('Drama'),
('Crime'),
('Action');

INSERT INTO MovieGenre (MovieID, GenreID)
VALUES 
(1, 1),
(1, 3),
(2, 2),
(3, 3);

INSERT INTO Actor (Name, Surname, Image, ImageThumb)
VALUES 
('Morgan', 'Freeman', NULL, NULL),
('Marlon', 'Brando', NULL, NULL),
('Heath', 'Ledger', NULL, NULL);

INSERT INTO MovieActor (MovieID, ActorID)
VALUES 
(1, 1),
(2, 2),
(3, 3);

INSERT INTO Hall (Name)
VALUES ('Hall 1'), ('Hall 2'), ('Hall 3');

INSERT INTO ViewMode (Name)
VALUES ('2D'), ('3D'), ('4DX');

INSERT INTO Screening (MovieID, HallID, ViewModeID, Date, Time, Price, StateMachine)
VALUES 
(1, 1, 1, '2024-04-04', '18:00:00', 10.00, NULL),
(2, 2, 2, '2024-04-05', '19:00:00', 12.00, NULL),
(3, 3, 3, '2024-04-06', '20:00:00', 15.00, NULL);

INSERT INTO PayPalPayment (UserID, Info)
VALUES 
(1, 'Payment information for John Doe'),
(2, 'Payment information for Jane Smith'),
(3, 'Payment information for Michael Johnson');

INSERT INTO Seat (Name, ScreeningID, IsReserved)
VALUES 
('A1', 1, 0),
('A2', 1, 0),
('B1', 2, 0),
('B2', 2, 0),
('C1', 3, 0),
('C2', 3, 0);

INSERT INTO Reservation (UserID, ScreeningID, SeatID, Date, NumberOfTickets, TotalPrice, Status)
VALUES 
(1, 1, 1, '2024-04-03', 1, 10.00, 'Confirmed'),
(2, 2, 3, '2024-04-03', 2, 24.00, 'Confirmed'),
(3, 3, 5, '2024-04-03', 1, 15.00, 'Confirmed');

INSERT INTO Purchase (UserID, ScreeningID, SeatID, Date, NumberOfTickets, TotalPrice, Status, PayPalPaymentID)
VALUES 
(1, 1, 1, '2024-04-03', 1, 10.00, 'Completed', 1),
(2, 2, 3, '2024-04-03', 2, 24.00, 'Completed', 2),
(3, 3, 5, '2024-04-03', 1, 15.00, 'Completed', 3);

INSERT INTO Rating (UserID, MovieID, Value, Comment)
VALUES 
(1, 1, 5, 'Great movie!'),
(2, 2, 4, 'Classic film.'),
(3, 3, 5, 'One of the best superhero movies.');