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
    Image VARBINARY(MAX)
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
    Image VARBINARY(MAX)
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
    Image VARBINARY(MAX)
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
    DateTime DATETIME,
    Price DECIMAL(10,2),
    StateMachine VARCHAR(50),
    FOREIGN KEY (MovieID) REFERENCES Movie(ID) ON DELETE CASCADE,
	FOREIGN KEY (HallID) REFERENCES Hall(ID) ON DELETE CASCADE,
    FOREIGN KEY (ViewModeID) REFERENCES ViewMode(ID) ON DELETE CASCADE
);

CREATE TABLE Seat (
    ID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(10)
);

CREATE TABLE ScreeningSeat (
    ScreeningID INT,
    SeatID INT,
    IsReserved BIT DEFAULT 0,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE CASCADE,
    PRIMARY KEY (ScreeningID, SeatID)
);

CREATE TABLE Payment (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    Provider VARCHAR(50),
    TransactionID VARCHAR(255),
    Amount DECIMAL(10,2),
    DateTime DATETIME,
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE CASCADE
);

CREATE TABLE Reservation (
    ID INT PRIMARY KEY IDENTITY,
    UserID INT,
    ScreeningID INT,
    DateTime DATETIME,
    NumberOfTickets INT,
    TotalPrice DECIMAL(10,2),
	PaymentID INT NULL,
	PaymentType VARCHAR(50) DEFAULT 'Cash',
	QRCodeBase64 NVARCHAR(MAX),
    FOREIGN KEY (UserID) REFERENCES [User](ID) ON DELETE NO ACTION,
    FOREIGN KEY (ScreeningID) REFERENCES Screening(ID) ON DELETE CASCADE,
	FOREIGN KEY (PaymentID) REFERENCES Payment(ID) ON DELETE SET NULL
);

CREATE TABLE ReservationSeat (
    ReservationID INT,
    SeatID INT,
	ReservedAt DATETIME,
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ID) ON DELETE CASCADE,
    FOREIGN KEY (SeatID) REFERENCES Seat(ID) ON DELETE CASCADE,
    PRIMARY KEY (ReservationID, SeatID)
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

INSERT INTO [User] (Name, Surname, Email, Username, PasswordSalt, PasswordHash, Image)
VALUES 
('Emma', 'Johnson', 'emma.j@example.com', 'emma_j', 'abcdefg12345', '$2y$10$uFj8G3cSJazj5VpShYYGYODSQ8xVOlBghxOGU5iGBt7mXc/Q8qM12', NULL),
('Michael', 'Smith', 'michael.s@example.com', 'michael_s', 'qwerty12345', '$2y$10$jHWmzGdZdfA4oUGZ9Efjzuj8sGp0fV9YzKyZUB41VTH4v2QGw3L/q', NULL),
('Olivia', 'Williams', 'olivia.w@example.com', 'olivia_w', '1234567890', '$2y$10$zJGeJDEYIlyuk3vm.V6EyO0RFVdoXvXy5F/SJxXTntMP0JArz5SdC', NULL),
('Ava', 'Brown', 'ava.brown@example.com', 'ava_b', 'passwordSalt1', 'passwordHash1', NULL),
('Liam', 'Davis', 'liam.davis@example.com', 'liam_d', 'passwordSalt2', 'passwordHash2', NULL),
('Sophia', 'Miller', 'sophia.miller@example.com', 'sophia_m', 'passwordSalt3', 'passwordHash3', NULL),
('Noah', 'Wilson', 'noah.wilson@example.com', 'noah_w', 'passwordSalt4', 'passwordHash4', NULL),
('Isabella', 'Moore', 'isabella.moore@example.com', 'isabella_m', 'passwordSalt5', 'passwordHash5', NULL),
('Ethan', 'Taylor', 'ethan.taylor@example.com', 'ethan_t', 'passwordSalt6', 'passwordHash6', NULL),
('Mia', 'Anderson', 'mia.anderson@example.com', 'mia_a', 'passwordSalt7', 'passwordHash7', NULL);

INSERT INTO Role (Name)
VALUES 
('User'),
('Admin');

INSERT INTO UserRole (UserID, RoleID)
VALUES 
(1, 1),
(2, 1),
(3, 2);

INSERT INTO Movie (Title, Duration, Synopsis, Image)
VALUES 
('The Shawshank Redemption', 142, 'Two imprisoned men bond over a number of years...', NULL),
('The Godfather', 175, 'The aging patriarch of an organized crime dynasty...', NULL),
('The Dark Knight', 152, 'When the menace known as the Joker wreaks havoc...', NULL),
('Inception', 148, 'A thief who enters the dreams of others to steal secrets from their subconscious...', NULL),
('The Matrix', 136, 'A computer hacker learns from mysterious rebels about the true nature of his reality...', NULL),
('Fight Club', 139, 'An insomniac office worker and a soap salesman build a global organization to help vent male aggression...', NULL),
('Pulp Fiction', 154, 'The lives of two mob hitmen, a boxer, a gangster’s wife, and a pair of diner bandits intertwine...', NULL),
('Forrest Gump', 142, 'The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold...', NULL),
('The Lord of the Rings: The Return of the King', 201, 'Gandalf and Aragorn lead the World of Men against Sauron''s army to end his reign over Middle-earth...', NULL),
('The Silence of the Lambs', 118, 'A young F.B.I. cadet must confide in an incarcerated and manipulative killer to receive his help on catching another serial killer...', NULL);

INSERT INTO Genre (Name)
VALUES 
('Drama'),
('Crime'),
('Action'),
('Comedy'),
('Thriller'),
('Science Fiction'),
('Fantasy'),
('Horror'),
('Romance'),
('Adventure');

INSERT INTO MovieGenre (MovieID, GenreID)
VALUES 
(1, 1),
(1, 2),
(2, 1),
(2, 2),
(3, 3),
(4, 1),
(4, 3),
(5, 3),
(5, 6),
(6, 1),
(6, 3),
(7, 1),
(7, 2),
(7, 3),
(8, 1),
(8, 4),
(9, 1),
(9, 6),
(10, 1),
(10, 2),
(10, 5);

INSERT INTO Actor (Name, Surname, Image)
VALUES 
('Morgan', 'Freeman', NULL),
('Marlon', 'Brando', NULL),
('Heath', 'Ledger', NULL),
('Leonardo', 'DiCaprio', NULL),
('Keanu', 'Reeves', NULL),
('Brad', 'Pitt', NULL),
('John', 'Travolta', NULL),
('Tom', 'Hanks', NULL),
('Elijah', 'Wood', NULL),
('Jodie', 'Foster', NULL),
('Christian', 'Bale', NULL),      
('Tom', 'Hardy', NULL),           
('Carrie-Anne', 'Moss', NULL),    
('Helena Bonham', 'Carter', NULL),
('Uma', 'Thurman', NULL),         
('Gary', 'Sinise', NULL),         
('Orlando', 'Bloom', NULL),       
('Anthony', 'Hopkins', NULL);

INSERT INTO MovieActor (MovieID, ActorID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(3, 11),
(4, 12),
(5, 13),
(6, 14),
(7, 15),
(8, 16),
(9, 17),
(10, 18);

INSERT INTO Hall (Name)
VALUES 
('Hall 1'), 
('Hall 2'), 
('Hall 3'),
('Hall 4'),
('Hall 5'),
('Hall 6'),
('Hall 7'),
('Hall 8'),
('Hall 9'),
('Hall 10');

INSERT INTO ViewMode (Name)
VALUES ('2D'), ('3D'), ('4DX'), ('IMAX'), ('Dolby Atmos'), ('ScreenX'), ('VR'), ('HFR');

INSERT INTO Screening (MovieID, HallID, ViewModeID, DateTime, Price, StateMachine)
VALUES 
(1, 1, 1, '2024-12-05 14:00:00', 10.50, 'active'),
(2, 2, 2, '2024-12-07 16:30:00', 13.00, 'draft'),
(3, 3, 3, '2024-12-08 19:00:00', 15.50, 'active'),
(4, 4, 4, '2024-12-09 15:00:00', 18.00, 'active'),
(5, 5, 5, '2024-12-11 18:30:00', 14.50, 'hidden'),
(6, 6, 1, '2024-12-12 17:00:00', 11.00, 'active'),
(7, 7, 2, '2024-12-14 20:00:00', 13.50, 'draft'),
(8, 8, 3, '2024-12-15 14:30:00', 16.00, 'active'),
(9, 9, 4, '2024-12-17 19:30:00', 19.00, 'active'),
(10, 10, 5, '2024-12-19 16:00:00', 15.00, 'hidden'),
(1, 2, 6, '2024-12-20 18:30:00', 14.00, 'active'),
(2, 3, 7, '2024-12-22 15:30:00', 17.50, 'draft'),
(3, 4, 8, '2024-12-23 19:00:00', 16.50, 'active'),
(4, 5, 1, '2024-12-25 14:00:00', 11.50, 'active'),
(5, 6, 2, '2024-12-27 17:30:00', 13.00, 'hidden');

INSERT INTO Seat (Name)
VALUES 
('A1'), ('A2'), ('A3'), ('A4'), ('A5'), ('A6'), ('A7'), ('A8'),
('B1'), ('B2'), ('B3'), ('B4'), ('B5'), ('B6'), ('B7'), ('B8'),
('C1'), ('C2'), ('C3'), ('C4'), ('C5'), ('C6'), ('C7'), ('C8'),
('D1'), ('D2'), ('D3'), ('D4'), ('D5'), ('D6'), ('D7'), ('D8'),
('E1'), ('E2'), ('E3'), ('E4'), ('E5'), ('E6'), ('E7'), ('E8'),
('F1'), ('F2'), ('F3'), ('F4'), ('F5'), ('F6'), ('F7'), ('F8');

DECLARE @ScreeningID INT = 1;

WHILE @ScreeningID <= 15
BEGIN
    INSERT INTO ScreeningSeat (ScreeningID, SeatID, IsReserved)
    SELECT TOP 15
        @ScreeningID,
        Seat.ID,
        1
    FROM 
        Seat
    WHERE 
        Seat.ID NOT IN (SELECT SeatID FROM ScreeningSeat WHERE ScreeningID = @ScreeningID)
    ORDER BY 
        NEWID();

    INSERT INTO ScreeningSeat (ScreeningID, SeatID, IsReserved)
    SELECT TOP 33
        @ScreeningID,
        Seat.ID,
        0
    FROM 
        Seat
    WHERE 
        Seat.ID NOT IN (SELECT SeatID FROM ScreeningSeat WHERE ScreeningID = @ScreeningID)
    ORDER BY 
        NEWID();

    SET @ScreeningID = @ScreeningID + 1;
END

INSERT INTO Payment (UserID, Provider, TransactionID, Amount, DateTime)
VALUES
(1, 'Stripe', 'txn_1', 21.00, '2024-09-10 14:00:00'),
(2, 'Stripe', 'txn_2', 10.50, '2024-09-10 14:00:00'),
(3, 'Cash', NULL, 52.00, '2024-09-10 16:30:00'),
(1, 'Stripe', 'txn_3', 39.00, '2024-09-10 16:30:00'),
(4, 'Cash', NULL, 15.50, '2024-09-10 19:00:00'),
(5, 'Stripe', 'txn_4', 31.00, '2024-09-10 19:00:00'),
(6, 'Stripe', 'txn_5', 90.00, '2024-09-11 15:00:00'),
(7, 'Cash', NULL, 14.50, '2024-09-11 18:30:00'),
(8, 'Stripe', 'txn_6', 33.00, '2024-09-12 17:00:00'),
(9, 'Cash', NULL, 44.00, '2024-09-12 17:00:00');

INSERT INTO Reservation (UserID, ScreeningID, DateTime, NumberOfTickets, TotalPrice, PaymentID, PaymentType, QRCodeBase64)
VALUES 
(1, 1, '2024-09-10 14:00:00', 2, 21.00, 1, 'Stripe', NULL),
(2, 1, '2024-09-10 14:00:00', 1, 10.50, 2, 'Stripe', NULL),
(3, 2, '2024-09-10 16:30:00', 4, 52.00, NULL, 'Cash', NULL),
(1, 2, '2024-09-10 16:30:00', 3, 39.00, 4, 'Stripe', NULL),
(4, 3, '2024-09-10 19:00:00', 1, 15.50, NULL, 'Cash', NULL),
(5, 3, '2024-09-10 19:00:00', 2, 31.00, 6, 'Stripe', NULL),
(6, 4, '2024-09-11 15:00:00', 5, 90.00, 7, 'Stripe', NULL),
(7, 5, '2024-09-11 18:30:00', 1, 14.50, NULL, 'Cash', NULL),
(8, 6, '2024-09-12 17:00:00', 3, 33.00, 9, 'Stripe', NULL),
(9, 6, '2024-09-12 17:00:00', 4, 44.00, NULL, 'Cash', NULL);

INSERT INTO ReservationSeat (ReservationID, SeatID, ReservedAt)
VALUES 
(1, 1, GETDATE()), 
(1, 2, GETDATE()),
(2, 3, GETDATE()),
(3, 4, GETDATE()), 
(3, 5, GETDATE()), 
(3, 6, GETDATE()),
(4, 7, GETDATE()),
(5, 8, GETDATE()),
(6, 9, GETDATE()), 
(6, 10, GETDATE()), 
(6, 11, GETDATE()), 
(6, 12, GETDATE());

INSERT INTO Rating (UserID, MovieID, Value, Comment)
VALUES 
(1, 1, 5, 'Great movie!'),
(2, 2, 4, 'Classic film.'),
(3, 3, 5, 'One of the best superhero movies.'),
(4, 4, 4, 'Interesting concept, but could be better.'),
(5, 5, 5, 'Mind-blowing! A must-watch.'),
(6, 6, 3, 'Not my favorite, but still entertaining.'),
(7, 7, 4, 'Very engaging and well-executed.'),
(4, 8, 5, 'Epic conclusion to the trilogy!'),
(5, 9, 4, 'Visually stunning and gripping story.'),
(6, 10, 3, 'Good thriller, but a bit predictable.');