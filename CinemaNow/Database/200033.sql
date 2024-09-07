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
    DateTime DATETIME,
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
('The Dark Knight', 152, 'When the menace known as the Joker wreaks havoc...', NULL, NULL),
('Inception', 148, 'A thief who enters the dreams of others to steal secrets from their subconscious...', NULL, NULL),
('The Matrix', 136, 'A computer hacker learns from mysterious rebels about the true nature of his reality...', NULL, NULL),
('Fight Club', 139, 'An insomniac office worker and a soap salesman build a global organization to help vent male aggression...', NULL, NULL),
('Pulp Fiction', 154, 'The lives of two mob hitmen, a boxer, a gangster’s wife, and a pair of diner bandits intertwine...', NULL, NULL),
('Forrest Gump', 142, 'The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold...', NULL, NULL),
('The Lord of the Rings: The Return of the King', 201, 'Gandalf and Aragorn lead the World of Men against Sauron''s army to end his reign over Middle-earth...', NULL, NULL),
('The Silence of the Lambs', 118, 'A young F.B.I. cadet must confide in an incarcerated and manipulative killer to receive his help on catching another serial killer...', NULL, NULL);

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

INSERT INTO Actor (Name, Surname, Image, ImageThumb)
VALUES 
('Morgan', 'Freeman', NULL, NULL),
('Marlon', 'Brando', NULL, NULL),
('Heath', 'Ledger', NULL, NULL),
('Leonardo', 'DiCaprio', NULL, NULL),
('Keanu', 'Reeves', NULL, NULL),
('Brad', 'Pitt', NULL, NULL),
('John', 'Travolta', NULL, NULL),
('Tom', 'Hanks', NULL, NULL),
('Elijah', 'Wood', NULL, NULL),
('Jodie', 'Foster', NULL, NULL),
('Christian', 'Bale', NULL, NULL),      
('Tom', 'Hardy', NULL, NULL),           
('Carrie-Anne', 'Moss', NULL, NULL),    
('Helena Bonham', 'Carter', NULL, NULL),
('Uma', 'Thurman', NULL, NULL),         
('Gary', 'Sinise', NULL, NULL),         
('Orlando', 'Bloom', NULL, NULL),       
('Anthony', 'Hopkins', NULL, NULL);

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
(1, 1, 1, '2024-09-10 14:00:00', 10.50, 'active'),
(2, 2, 2, '2024-09-10 16:30:00', 13.00, 'draft'),
(3, 3, 3, '2024-09-10 19:00:00', 15.50, 'active'),
(4, 4, 4, '2024-09-11 15:00:00', 18.00, 'active'),
(5, 5, 5, '2024-09-11 18:30:00', 14.50, 'hidden'),
(6, 6, 1, '2024-09-12 17:00:00', 11.00, 'active'),
(7, 7, 2, '2024-09-12 20:00:00', 13.50, 'draft'),
(8, 8, 3, '2024-09-13 14:30:00', 16.00, 'active'),
(9, 9, 4, '2024-09-13 19:30:00', 19.00, 'active'),
(10, 10, 5, '2024-09-14 16:00:00', 15.00, 'hidden'),
(1, 2, 6, '2024-09-14 18:30:00', 14.00, 'active'),
(2, 3, 7, '2024-09-15 15:30:00', 17.50, 'draft'),
(3, 4, 8, '2024-09-15 19:00:00', 16.50, 'active'),
(4, 5, 1, '2024-09-16 14:00:00', 11.50, 'active'),
(5, 6, 2, '2024-09-16 17:30:00', 13.00, 'hidden');

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