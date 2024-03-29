﻿CREATE DATABASE FootballDB;

USE  FootballDB;

--2.1 a....
GO;
CREATE PROCEDURE createAllTables
AS
	CREATE TABLE SystemUser(
		username VARCHAR(20),
		password VARCHAR(20),
		CONSTRAINT pk_system_user PRIMARY KEY(username)
	);

	CREATE TABLE Stadium(
		id INT IDENTITY,
		name VARCHAR(20) UNIQUE,
		capacity INT,
		location VARCHAR(20),
		status BIT DEFAULT 1, -- 1 means available, 0 means unavailable
		CONSTRAINT pk_stadium PRIMARY KEY(id)
	);

	CREATE TABLE Club(
		id INT IDENTITY,
		name VARCHAR(20) UNIQUE,
		location VARCHAR(20),
		CONSTRAINT pk_club PRIMARY KEY(id)
	);

	CREATE TABLE StadiumManager(
		username VARCHAR(20) UNIQUE,
		id INT IDENTITY UNIQUE,
		name VARCHAR(20),
		stadium_id INT,
		CONSTRAINT pk_stadium_manager PRIMARY KEY(id),
		FOREIGN KEY(username) REFERENCES SystemUser(username) ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY(stadium_id) REFERENCES Stadium(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE ClubRepresentative(
		username VARCHAR(20) UNIQUE,
		id INT IDENTITY UNIQUE,
		name VARCHAR(20),
		club_id INT,
		CONSTRAINT pk_club_rep PRIMARY KEY(id),
		FOREIGN KEY(username) REFERENCES SystemUser(username) ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY(club_id) REFERENCES Club(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE Fan(
		username VARCHAR(20) UNIQUE,
		national_id VARCHAR(20) UNIQUE,
		phone INT, --should be varchar but in proc addFan the phone input is int
		name VARCHAR(20),
		address VARCHAR(20),
		status BIT DEFAULT 1, -- 1 means unblocked, 0 means blocked
		birth_date DATE,
		CONSTRAINT pk_fan PRIMARY KEY(national_id),
		FOREIGN KEY(username) REFERENCES SystemUser(username) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE SportsAssociationManager(
		username VARCHAR(20) UNIQUE,
		id INT IDENTITY UNIQUE,
		name VARCHAR(20),
		CONSTRAINT pk_sam PRIMARY KEY(id),
		FOREIGN KEY(username) REFERENCES SystemUser(username) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE SystemAdmin(
		username VARCHAR(20) UNIQUE,
		id INT IDENTITY UNIQUE,
		name VARCHAR(20),
		CONSTRAINT pk_system_admin PRIMARY KEY(id),
		FOREIGN KEY(username) REFERENCES SystemUser(username) ON DELETE CASCADE ON UPDATE CASCADE,
	);

	CREATE TABLE Match(
		id INT IDENTITY,
		start_time DATETIME,
		end_time DATETIME,
		stadium_id INT,
		host_id INT,
		guest_id INT,
		CONSTRAINT pk_Match PRIMARY KEY(id),
		FOREIGN KEY(host_id) REFERENCES Club(id) ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY(guest_id) REFERENCES Club(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
		FOREIGN KEY(stadium_id) REFERENCES Stadium(id) ON DELETE SET NULL ON UPDATE CASCADE
	);

	CREATE TABLE Ticket(
		id INT IDENTITY,
		status BIT DEFAULT 1, -- 1 means available, 0 means unavailable
		match_id INT,
		CONSTRAINT pk_ticket PRIMARY KEY(id),
		FOREIGN KEY(match_id) REFERENCES Match(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE TicketBuyingTransactions(
		fan_national_id VARCHAR(20),
		ticket_id INT,
		CONSTRAINT pk_ticketBuyingTransactions PRIMARY KEY(ticket_id),
		FOREIGN KEY(fan_national_id) REFERENCES Fan(national_id) ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY(ticket_id) REFERENCES Ticket(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

	CREATE TABLE HostRequest(
		id INT IDENTITY,
		status VARCHAR(20) DEFAULT 'unhandled', --unhandled or accepted or rejected
		match_id INT,
		smd INT,
		crd INT,
		CONSTRAINT pk_host_request PRIMARY KEY(id),
		CONSTRAINT check_status CHECK(status='accepted' OR status='rejected' OR status='unhandled'),
		FOREIGN KEY(smd) REFERENCES StadiumManager(id) ON DELETE CASCADE ON UPDATE CASCADE,
		FOREIGN KEY(crd) REFERENCES ClubRepresentative(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
		FOREIGN KEY(match_id) REFERENCES Match(id) ON DELETE NO ACTION ON UPDATE NO ACTION
	);
GO;

--2.1 b
GO;
CREATE PROC dropAllTables
AS
	DROP TABLE IF EXISTS 
	TicketBuyingTransactions,
	SportsAssociationManager,
	SystemAdmin,
	Ticket,
	HostRequest,
	Match,
	Fan,
	StadiumManager,
	ClubRepresentative,
	SystemUser,
	Stadium,
	Club;
GO;

--2.1 c
GO;
CREATE PROC dropAllProceduresFunctionsViews
AS
	DROP PROC IF EXISTS 
	createAllTables,
	dropAllTables,
	clearAllTables,
	addAssociationManager,
	addNewMatch,
	deleteMatch,
	deleteMatchesOnStadium,
	addClub,
	addTicket,
	deleteClub,
	addStadium,
	deleteStadium,
	blockFan,
	unblockFan,
	addRepresentative,
	addHostRequest,
	addStadiumManager,
	acceptRequest,
	rejectRequest,
	addFan,
	purchaseTicket,
	updateMatchHost;

	DROP VIEW IF EXISTS
	allAssocManagers,
	allClubRepresentatives,
	allStadiumManagers,
	allFans,
	allMatches,
	allTickets,
	allCLubs,
	allStadiums,
	allRequests,
	clubsWithNoMatches,
	matchesPerTeam,
	clubsNeverMatched;

	DROP FUNCTION IF EXISTS
	viewAvailableStadiumsOn,
	allUnassignedMatches,
	allPendingRequests,
	upcomingMatchesOfClub,
	availableMatchesToAttend,
	clubsNeverPlayed,
	matchWithHighestAttendance,
	matchesRankedByAttendance,
	requestsFromClub;
GO;

--2.1 d
GO;
CREATE PROC clearAllTables
AS
	DELETE FROM TicketBuyingTransactions;
	DELETE FROM SportsAssociationManager;
	DELETE FROM SystemAdmin;
	DELETE FROM Ticket;
	DELETE FROM HostRequest;
	DELETE FROM Match;
	DELETE FROM Fan;
	DELETE FROM StadiumManager;
	DELETE FROM ClubRepresentative;
	DELETE FROM SystemUser;
	DELETE FROM Stadium;
	DELETE FROM Club;
GO;

-------------------------------------------------------------------

--2.2 a
GO;
CREATE VIEW allAssocManagers AS
	SELECT S.username ,U.password ,S.name
	FROM SportsAssociationManager S
		INNER JOIN SystemUser U ON U.username = S.username;
GO;

--2.2 b
GO;
CREATE VIEW allClubRepresentatives AS
	SELECT R.username , U.password ,R.name AS club_rep_name, C.name AS club_name
	From ClubRepresentative R
		INNER JOIN Club C ON C.id = R.club_id
		INNER JOIN SystemUser U ON U.username = R.username;
GO;

--2.2 c
GO;
CREATE VIEW allStadiumManagers AS
	SELECT M.username , U.password,M.name AS stadium_manager_name, S.name AS stadium_name
	FROM StadiumManager M
		INNER JOIN Stadium S ON S.id = M.stadium_id
		INNER JOIN SystemUser U ON U.username = M.username;
GO;

--2.2 d
GO;
CREATE VIEW allFans AS
	SELECT F.username, U.password ,F.name , F.national_id , F.birth_date , F.status
	From Fan F
		INNER JOIN SystemUser U ON U.username = F.username;
GO;

--2.2 e 
GO; 
CREATE VIEW allMatches AS
	SELECT C1.name AS host_club , C2.name AS guest_club , M.start_time
	FROM Match M
		INNER JOIN Club C1 ON C1.id = M.host_id 
		INNER JOIN Club C2 ON C2.id = M.guest_id; 
GO;

--2.2 f
GO; 
CREATE VIEW allTickets AS 
	SELECT H.name AS host_club, A.name AS guest_club, S.name AS stadium_name , M.start_time
	FROM Ticket T
		INNER JOIN Match M ON M.id = T.match_id 
		INNER JOIN Club H ON H.id = M.host_id
		INNER JOIN CLUB A ON A.id = M.guest_id
		INNER JOIN Stadium S on S.id = M.stadium_id;
GO;

--2.2 g
GO;
CREATE VIEW allCLubs AS
	SELECT C.name , C.location
	FROM Club C
GO;

--2.2 h
GO; 
CREATE VIEW allStadiums AS
	SELECT S.name , S.location , S.capacity , S.status 
	From Stadium S
GO;

--2.2 i
GO;
CREATE VIEW allRequests AS 
	SELECT CR.username AS club_rep_username, SM.username AS stadium_manager_username, R.status
	FROM HostRequest R
		INNER JOIN ClubRepresentative CR on CR.id = R.crd
		INNER JOIN StadiumManager SM ON SM.id = R.smd
GO;

-------------------------------------------------------------------

--2.3 i
GO;
CREATE PROC addAssociationManager 
	@name VARCHAR(20),
	@username VARCHAR(20),
	@password VARCHAR(20)
	AS
	IF NOT EXISTS (
		SELECT * 
		FROM SystemUser S 
		WHERE S.username = @username
	)
	BEGIN
		INSERT INTO SystemUser(username,password) VALUES (@username,@password);
		INSERT INTO SportsAssociationManager(username, name) VALUES (@username , @name);
	END
	ELSE
	BEGIN
		PRINT 'This User is already in the Database.';
	END
GO;

--2.3 ii
GO;
CREATE PROC addNewMatch
	@hostclub VARCHAR(20),
	@guestclub VARCHAR(20),
	@starttime DATETIME,
	@endtime DATETIME
	AS 

	DECLARE @host INT
	SELECT @host = C.id
	FROM Club C
	WHERE C.name = @hostclub;

	DECLARE @guest INT
	SELECT @guest = C.id
	FROM Club C
	Where C.name = @guestclub;
	INSERT INTO Match (start_time , host_id , guest_id,end_time) VALUES (@starttime , @host , @guest , @endtime);
GO;

--2.3 iii
GO;
CREATE VIEW clubsWithNoMatches AS
	SELECT C.name
	FROM Club C
	WHERE NOT EXISTS (
			SELECT C1.name 
			FROM Club C1
				INNER JOIN Match M ON M.host_id = C1.id
			WHERE C.id = C1.id
	)
	AND  NOT EXISTS (
			SELECT C2.name 
			FROM Club C2
				INNER JOIN Match M ON M.guest_id = C2.id
			WHERE C.id = C2.id
	);
-- OR we can use outer join
GO;
--2.3 iv
GO;
CREATE PROC deleteMatch 
	@namehostclub VARCHAR(20),
	@nameguestclub VARCHAR(20)	
	AS

	DECLARE @host INT
	SELECT @host = C.id
	FROM Club C
	WHERE C.name = @namehostclub;

	DECLARE @guest INT
	SELECT @guest = C.id
	FROM Club C
	Where C.name = @nameguestclub;

	DELETE FROM HostRequest
	WHERE match_id IN (
		SELECT id
		FROM Match
		WHERE (Match.host_id = @host AND Match.guest_id = @guest)
	);

	DELETE FROM Match 
	WHERE (Match.host_id = @host AND Match.guest_id = @guest) 
GO;

--2.3 v
GO;
CREATE PROC deleteMatchesOnStadium
	@nameOfStadium VARCHAR(20)
	AS

	DECLARE @id INT
	SELECT @id = S.id
	FROM Stadium S
	WHERE S.name = @nameOfStadium;

	DELETE FROM Match 
	WHERE Match.stadium_id = @id AND Match.start_time>CURRENT_TIMESTAMP;

--2.3 vi
GO;
CREATE PROC addClub
	@nameOfClub VARCHAR(20),
	@nameOfLocation VARCHAR(20)
	AS

	INSERT INTO Club (name,location) VALUES (@nameOfClub,@nameOfLocation);
GO;
--2.3 vii
GO;
CREATE PROC addTicket
	@nameHostClub VARCHAR(20),
	@nameGuestClub VARCHAR(20),
	@startTime DATETIME
	AS

	DECLARE @hostId INT
	SELECT @hostId = C.id
	FROM Club C
	WHERE C.name = @nameHostClub;

	DECLARE @guestId INT
	SELECT @guestId = C.id
	FROM Club C
	Where C.name = @nameGuestClub;

	DECLARE @matchId INT
	SELECT @matchId = M.id
	FROM Match M
	WHERE M.start_time = @startTime AND M.host_id = @hostId AND M.guest_id = @guestId

	INSERT INTO Ticket (match_id) VALUES (@matchId);
GO;

--2.3 viii
GO;
CREATE PROC deleteClub
	@clubName VARCHAR(20)
	AS

	DECLARE @id INT
	SELECT @id = C.id
	FROM Club C
	WHERE C.name = @clubName;

	DELETE FROM HostRequest
	WHERE crd IN (
		SELECT id
		FROM ClubRepresentative
		WHERE club_id=@id
	);

	DELETE FROM Match
	WHERE guest_id = @id

	DELETE FROM Club
	WHERE Club.id = @id;
GO;

--2.3 ix
GO;
CREATE PROC addStadium
	@stadiumName VARCHAR(20),
	@location VARCHAR(20),
	@capacity VARCHAR(20)
	AS

	INSERT INTO Stadium (name,capacity,location) VALUES (@stadiumName,@capacity,@location);
GO;
--2.3 x
GO;
CREATE PROC deleteStadium
	@stadiumName VARCHAR(20)
	AS

	DECLARE @id INT
	SELECT @id = S.id
	FROM Stadium S
	WHERE S.name = @stadiumName;
	
	DELETE FROM Ticket
	WHERE match_id IN (
		SELECT id
		FROM Match
		WHERE stadium_id = @id AND start_time>CURRENT_TIMESTAMP
	)

	DELETE FROM Stadium 
	WHERE Stadium.id = @id;

GO;

--2.3 xi
GO;
CREATE PROC blockFan
	@fanNationalId VARCHAR(20)
	AS

	UPDATE Fan
	SET status = 0
	WHERE Fan.national_id = @fanNationalId

--2.3 xii
GO;
CREATE PROC unblockFan
	@fanNationalId VARCHAR(20)
	AS

	UPDATE Fan
	SET status = 1
	WHERE Fan.national_id = @fanNationalId

--2.3 xiii
GO;
CREATE PROC addRepresentative
	@repName VARCHAR(20),
	@clubName VARCHAR(20),
	@username VARCHAR(20),
	@password VARCHAR(20)
	AS

	DECLARE @clubId INT
	SELECT @clubId = C.id
	FROM Club C
	WHERE C.name = @clubName
	IF (@clubId IS NOT NULL)
		IF NOT EXISTS (
			SELECT * 
			FROM SystemUser S 
			WHERE S.username = @username
		)
		BEGIN
		IF NOT EXISTS (
			SELECT *
			FROM ClubRepresentative C
			WHERE C.club_id = @clubId
		)
			BEGIN
				INSERT INTO SystemUser(username,password) VALUES (@username,@password);
				INSERT INTO ClubRepresentative (username,name,club_id) VALUES (@username,@repName,@clubId);
			END
			ELSE
			BEGIN
				PRINT 'This Club already has a Club Representative.';
			END
		END
		ELSE
		BEGIN
			PRINT 'This User is already in the Database.';
		END
	ELSE 
	BEGIN
		PRINT 'This Club isnot in our Database.';
	END
GO;

--2.3 xiv
GO;
CREATE FUNCTION viewAvailableStadiumsOn (@datetime DATETIME)
	RETURNS TABLE
	AS
	RETURN
		SELECT S.name,S.location,S.capacity
		FROM Stadium S
		WHERE S.status=1 AND NOT EXISTS(
			SELECT * 
			FROM Match M
			WHERE  S.id = M.stadium_id AND CAST(M.start_time AS DATE) = @datetime
		)
GO;

--2.3 xv
GO;
CREATE PROC addHostRequest 
	@clubName VARCHAR(20),
	@stadiumName VARCHAR(20),
	@startTime DATETIME
	AS 

	DECLARE @clubRepId INT;
	DECLARE @hostId INT;
	SELECT @clubRepId = CR.id, @hostId = C.id
	FROM ClubRepresentative CR
		INNER JOIN Club C on C.id = CR.club_id
	WHERE C.name = @clubName

	DECLARE @stadiumManagerId INT;
	SELECT @stadiumManagerId = SM.id
	FROM StadiumManager SM
		INNER JOIN Stadium S on S.id = SM.stadium_id
	WHERE S.name = @stadiumName

	DECLARE @matchId INT
	SELECT @matchId = M.id
	FROM Match M
	WHERE M.host_id = @hostId AND M.start_time = @startTime
	IF (@matchId IS NOT NULL AND @stadiumManagerId IS NOT NULL AND @clubRepId IS NOT NULL)
	BEGIN
		INSERT INTO HostRequest(match_id,smd,crd) VALUES (@matchId,@stadiumManagerId,@clubRepId);
	END
	ELSE 
	BEGIN
		PRINT 'One of entries is null as it was not found in the database'
	END
GO;

--2.3 xvi
GO;
CREATE FUNCTION allUnassignedMatches(@clubName VARCHAR(20))
	RETURNS TABLE
	AS 

	RETURN
		SELECT C2.name AS guest_club_name, M.start_time
		FROM Match M
			INNER JOIN Club C1 ON C1.id = M.host_id
			INNER JOIN Club C2 ON C2.id = M.guest_id
		WHERE M.stadium_id IS NULL AND @clubName = C1.name
GO;

--2.3 xvii
GO;
CREATE PROC addStadiumManager
	@name VARCHAR(20),
	@stadiumName VARCHAR(20),
	@username VARCHAR(20),
	@password VARCHAR(20)
	AS

	DECLARE @stadiumId INT
	SELECT @stadiumId = S.id
	FROM Stadium S
	WHERE S.name = @stadiumName

	IF (@stadiumId is NOT NULL)
	BEGIN
		IF NOT EXISTS (
			SELECT * 
			FROM SystemUser S 
			WHERE S.username = @username
		)
		BEGIN
		IF NOT EXISTS (
			SELECT *
			FROM StadiumManager SM
			WHERE SM.stadium_id = @stadiumId
		)
			BEGIN
				INSERT INTO SystemUser(username,password) VALUES (@username,@password);
				INSERT INTO StadiumManager(username,name,stadium_id) VALUES (@username,@name,@stadiumId)
			END
			ELSE
			BEGIN
				PRINT 'This Stadium already has a Stadium Manager.';
			END
		END
		ELSE
		BEGIN
			PRINT 'This User is already in the Database.';
		END
	END
	ELSE
	BEGIN 
	PRINT 'This Stadium isnot in our database'
	END
GO;

--2.3 xviii
GO;
CREATE FUNCTION allPendingRequests (@username VARCHAR(20))
	RETURNS TABLE
	AS

	RETURN 
		SELECT CR.name AS club_rep_name, C.name AS competing_club,M.start_time
		FROM HostRequest H
			INNER JOIN StadiumManager SM ON H.smd=SM.id
			INNER JOIN ClubRepresentative CR ON H.crd = CR.id
			INNER JOIN Match M ON M.id = H.match_id
			INNER JOIN Club C ON C.id = M.guest_id
		WHERE SM.username = @username AND H.status = 'unhandled'
GO;

GO;
--2.3 xix
CREATE PROC acceptRequest
	@stadiumManagerUserName VARCHAR(20),
	@hostingClubName VARCHAR(20),
	@guestClubName VARCHAR(20),
	@matchStartTime VARCHAR(20)
	AS

	DECLARE @stadiumID INT
	DECLARE @smd INT
	SELECT @smd =  SM.id, @stadiumID = SM.stadium_id
	FROM StadiumManager SM
	WHERE SM.username = @stadiumManagerUserName

	DECLARE @hostId INT
	SELECT @hostId = C.id
	FROM Club C
	WHERE C.name = @hostingClubName

	DECLARE @guestId INT
	SELECT @guestId = C.id
	FROM Club C
	WHERE C.name = @guestClubName
	
	DECLARE @requestId INT
	SELECT @requestId = H.id
	FROM HostRequest H 
		INNER JOIN Match M ON M.id = H.match_id
	WHERE start_time= @matchStartTime AND host_id= @hostId AND guest_id= @guestId AND H.smd = @smd 

	DECLARE @matchID INT 
	SELECT @matchID = M.id
	FROM Match M
	WHERE start_time= @matchStartTime AND host_id= @hostId AND guest_id= @guestId
	
	UPDATE HostRequest
	SET status= 'accepted'
	where id=@requestId

	UPDATE Match
	SET stadium_id = @stadiumID
	WHERE start_time= @matchStartTime AND host_id= @hostId AND guest_id= @guestId

	DECLARE @capacity INT
	SELECT @capacity = S.capacity 
	FROM Stadium S
	WHERE S.id = @stadiumID ;

	DECLARE @counter INT
	SET @counter = 1
	WHILE (@counter <= @capacity)
	BEGIN
		INSERT INTO Ticket (match_id) VALUES(@matchID);
		SET @counter = @counter+1;
	END
GO;

--2.3 xx
GO;
CREATE PROC rejectRequest
	@stadiumManagerUserName VARCHAR(20),
	@hostingClubName VARCHAR(20),
	@guestClubName VARCHAR(20),
	@matchStartTime VARCHAR(20)
	AS

	DECLARE @smd INT
	SELECT @smd = SM.id
	FROM StadiumManager SM
	WHERE SM.username = @stadiumManagerUserName

	DECLARE @hostId INT
	SELECT @hostId = C.id
	FROM Club C
	WHERE C.name = @hostingClubName

	DECLARE @guestId INT
	SELECT @guestId = C.id
	FROM Club C
	WHERE C.name = @guestClubName
	
	DECLARE @requestId INT
	SELECT @requestId = H.id
	FROM HostRequest H 
		INNER JOIN Match M ON M.id = H.match_id
	WHERE start_time= @matchStartTime AND host_id=@hostId AND guest_id=@guestId AND H.smd = @smd

	UPDATE HostRequest
	SET status='rejected'
	WHERE id=@requestId

	UPDATE Match
	SET stadium_id = NULL
	WHERE start_time= @matchStartTime AND host_id= @hostId AND guest_id= @guestId
	
	DECLARE @matchId INT
	SELECT @matchId = id
	FROM Match
	WHERE start_time= @matchStartTime AND host_id= @hostId AND guest_id= @guestId
	
	DELETE FROM Ticket
	WHERE match_id = @matchId
GO;

--2.3 xxi
GO;
CREATE PROC addFan
	@username VARCHAR(20),
	@password VARCHAR(20),
	@name VARCHAR(20),
	@nationalIdNumber VARCHAR(20),
	@birthDate date,
	@address VARCHAR(20),
	@phoneNumber INT
	AS
	IF NOT EXISTS (
		SELECT * 
		FROM SystemUser S 
		WHERE S.username = @username
	)
	BEGIN
		INSERT INTO SystemUser(username,password) VALUES (@username,@password);
		INSERT INTO Fan(username,name,national_id,birth_date,address,phone) VALUES (@username,@name,@nationalIdNumber,@birthDate,@address,@phoneNumber);
	END
	ELSE
	BEGIN
		PRINT 'This User is already in the Database.';
	END
GO;
--2.3 xxii 
GO;
CREATE FUNCTION upcomingMatchesOfClub (@clubName VARCHAR(20))
	RETURNS TABLE
	AS

	RETURN 
		SELECT C.name AS host_club_name, C2.name AS competing_club_name,M.start_time,S.name AS stadium_name
		FROM Match M 
			INNER JOIN Club C ON C.id = M.host_id
			INNER JOIN Club C2 on C2.id =M.guest_id
			INNER JOIN Stadium S on S.id=M.stadium_id
		WHERE  C.name = @clubName AND M.start_time> CURRENT_TIMESTAMP

--2.3 xxiii
GO;
CREATE FUNCTION availableMatchesToAttend (@date DATETIME)
	RETURNS TABLE
	AS

	RETURN 
		SELECT C.name AS host_club_name, C2.name AS guest_club_name,M.start_time,S.name AS stadium_name
		FROM Match M 
			INNER JOIN Club C ON C.id = M.host_id
			INNER JOIN Club C2 on C2.id =M.guest_id
			INNER JOIN Stadium S on S.id=M.stadium_id
			INNER JOIN Ticket T on T.match_id=M.id
		WHERE T.status=1 AND M.start_time>=@date
GO;

--2.3 xxiv
GO;
CREATE PROC purchaseTicket
    @nationalidnumber VARCHAR(20),
	@nameHostClub VARCHAR(20),
	@nameGuestClub VARCHAR(20),
	@startTime DATETIME
	AS

	DECLARE @username VARCHAR(20)
	DECLARE @fanstatus BIT
	SELECT @username = F.username,@fanstatus = F.status
	FROM Fan F
	WHERE F.national_id = @nationalidnumber;


	DECLARE @hostId INT
	SELECT @hostId = C.id
	FROM Club C
	WHERE C.name = @nameHostClub;

	DECLARE @guestId INT
	SELECT @guestId = C.id
	FROM Club C
	Where C.name = @nameGuestClub;

	DECLARE @matchId INT
	SELECT @matchId = M.id
	FROM Match M
	WHERE M.start_time = @startTime AND M.host_id = @hostId AND M.guest_id = @guestId
	
	IF @username is NOT NULL
	BEGIN
		IF @matchId IS NOT NULL
		BEGIN
			IF @fanstatus = 1
			BEGIN
				IF NOT EXISTS(
					SELECT T.id
					FROM Ticket T
					WHERE T.status = 1 AND T.match_id = @matchId
				)
				BEGIN
					PRINT 'There is no tickets available';
				END
				ELSE 
				BEGIN
					DECLARE @ticketId INT
					SELECT TOP 1 @ticketId = id 
					FROM Ticket
					WHERE status = 1 AND match_id = @matchId 

					INSERT INTO TicketBuyingTransactions VALUES (@nationalidnumber,@ticketId);

					UPDATE TICKET 
					SET status = 0
					WHERE status = 1 AND id = @ticketId
				END
			END
			ELSE
			BEGIN
				PRINT 'This User is Blocked';
			END
		END
		ELSE
		BEGIN
			PRINT 'There is no match with the given information';
		END
	END
	ELSE
	BEGIN
		PRINT 'This Username isnot in the Database';
	END
GO;

--2.3 xxv
GO;
CREATE PROC updateMatchHost
	@nameHostClub VARCHAR(20),
	@nameGuestClub VARCHAR(20),
	@startTime DATETIME
	AS

	DECLARE @hostId INT
	SELECT @hostId = C.id
	FROM Club C
	WHERE C.name = @nameHostClub;

	DECLARE @guestId INT
	SELECT @guestId = C.id
	FROM Club C
	Where C.name = @nameGuestClub;

	DECLARE @matchId INT
	SELECT @matchId = M.id
	FROM Match M
	WHERE M.start_time = @startTime AND M.host_id = @hostId AND M.guest_id = @guestId

	UPDATE Match
	SET host_id= @guestId, guest_id=@hostId, stadium_id = NULL
	WHERE host_id=@hostId AND guest_id=@guestId
GO;

--2.3 xxvi
GO;
CREATE VIEW matchesPerTeam
AS
	SELECT C.name, COUNT(*) AS Match_per_club
	FROM Match M1
		INNER JOIN Club C ON (C.id = M1.host_id OR C.id=M1.guest_id)
	WHERE M1.end_time<CURRENT_TIMESTAMP AND M1.stadium_id IS NOT NULL
	GROUP BY C.name
GO;

--xxvii
GO;
CREATE VIEW clubsNeverMatched
AS
	SELECT C1.name AS club1_name , C2.name AS club2_name
	FROM Club C1, Club C2
	WHERE NOT EXISTS(
		SELECT * 
		FROM Match M
		WHERE (M.host_id = C1.id AND M.guest_id = C2.id) AND stadium_id IS NOT NULL AND M.end_time<CURRENT_TIMESTAMP
	) AND NOT EXISTS (
		SELECT * 
		FROM Match M
		WHERE (M.host_id = C2.id AND M.guest_id = C1.id) AND stadium_id IS NOT NULL AND M.end_time<CURRENT_TIMESTAMP
	) AND C1.id > C2.id
GO;

GO;
--2.3 xxviii
CREATE FUNCTION clubsNeverPlayed (@clubName VARCHAR(20))
	RETURNS TABLE
	AS
	RETURN 
		SELECT C2.name AS club2_name
		FROM Club C1, Club C2
		WHERE C1.name = @clubName AND C2.name <> @clubName AND NOT EXISTS(
			SELECT * 
			FROM Match M
			WHERE (M.host_id = C1.id AND M.guest_id = C2.id)  AND stadium_id IS NOT NULL AND M.end_time<CURRENT_TIMESTAMP
		) AND NOT EXISTS (
			SELECT * 
			FROM Match M
			WHERE (M.host_id = C2.id AND M.guest_id = C1.id) AND stadium_id IS NOT NULL AND M.end_time<CURRENT_TIMESTAMP
		) 
GO;

--2.3 xxix
GO;
CREATE FUNCTION matchWithHighestAttendance ()
	RETURNS TABLE
	AS 
	RETURN 
		SELECT host.name AS host_name, guest.name AS guest_name
		FROM Match Mat
			INNER JOIN Club host on Mat.host_id = host.id
			INNER JOIN Club guest on Mat.guest_id = guest.id
			INNER JOIN Ticket T ON Mat.id = T.match_id
			INNER JOIN TicketBuyingTransactions TBT ON T.id = TBT.ticket_id
		GROUP BY host.name , guest.name, Mat.id
		HAVING COUNT(TBT.ticket_id) = (
			SELECT MAX(count_of_tickets)
			FROM (
				SELECT COUNT(TBT.ticket_id) AS count_of_tickets
				FROM Match Mat
					INNER JOIN Club host on Mat.host_id = host.id
					INNER JOIN Club guest on Mat.guest_id = guest.id
					INNER JOIN Ticket T ON Mat.id = T.match_id
					INNER JOIN TicketBuyingTransactions TBT ON T.id = TBT.ticket_id
				GROUP BY host.name , guest.name, Mat.id
			) AS T
		)
GO;

--2.3 xxx
GO;
CREATE FUNCTION matchesRankedByAttendance()
	RETURNS TABLE
	AS 
	RETURN 
		SELECT host.name AS host_name, guest.name AS guest_name , COUNT(TBT.ticket_id) AS count_of_tickets
		FROM Match Mat
			INNER JOIN Club host ON Mat.host_id = host.id
			INNER JOIN Club guest ON Mat.guest_id = guest.id
			LEFT OUTER JOIN 
			(
			Ticket T
				INNER JOIN TicketBuyingTransactions TBT ON T.id = TBT.ticket_id
			) ON T.match_id = Mat.id
		WHERE Mat.end_time < CURRENT_TIMESTAMP
		GROUP BY host.name , guest.name, Mat.id
		ORDER BY COUNT(TBT.ticket_id) DESC
		OFFSET 0 ROWS
GO;

--2.3 xxxi
GO;
CREATE FUNCTION requestsFromClub(@stadiumName varchar(20) , @clubName varchar(20))
	RETURNS TABLE 
	AS
	RETURN 
		SELECT host.name AS host_club, guest.name AS guest_club
		FROM Match Mat
			INNER JOIN Club host on Mat.host_id = host.id
			INNER JOIN Club guest on Mat.guest_id = guest.id
			INNER JOIN HostRequest H ON H.match_id = Mat.id
			INNER JOIN StadiumManager SM ON H.smd = SM.id
			INNER JOIN Stadium S ON S.id = SM.stadium_id
			INNER JOIN ClubRepresentative CR ON CR.id = H.crd
		WHERE host.name = @clubName AND S.name = @stadiumName
GO;

--------------------------------------------------------
--added proc & functions
GO;
CREATE PROC getClubOfRep
	@username VARCHAR(20)
	AS
	SELECT C.name , C.location
	From ClubRepresentative R
		INNER JOIN Club C ON C.id = R.club_id
	WHERE R.username = @username
GO;

CREATE FUNCTION upcomingMatchesOfClub2 (@clubName VARCHAR(20))
	RETURNS TABLE
	AS

	RETURN 
		SELECT C.name AS host_club_name, C2.name AS competing_club_name,M.start_time,M.end_time,S.name AS stadium_name
		FROM Match M 
			INNER JOIN Club C ON C.id = M.host_id
			INNER JOIN Club C2 on C2.id = M.guest_id
			LEFT OUTER JOIN Stadium S on S.id=M.stadium_id
		WHERE  (C.name = @clubName OR C2.name = @clubName) AND M.start_time> CURRENT_TIMESTAMP
GO;

CREATE FUNCTION availableMatchesToAttend2 (@date DATETIME)
	RETURNS TABLE
	AS

	RETURN 
		SELECT C.name AS host_club_name, C2.name AS guest_club_name,S.name AS stadium_name, S.location
		FROM Match M 
			INNER JOIN Club C ON C.id = M.host_id
			INNER JOIN Club C2 on C2.id =M.guest_id
			INNER JOIN Stadium S on S.id=M.stadium_id
			INNER JOIN Ticket T on T.match_id=M.id
		WHERE T.status=1 AND M.start_time>=@date
GO;

CREATE PROC getStadiumOfManager 
@username VARCHAR(20)
AS
	SELECT S.name, S.location, S.capacity, S.status
	FROM StadiumManager M
		INNER JOIN Stadium S ON S.id = M.stadium_id
	WHERE M.username=@username
GO;

CREATE FUNCTION requests(@stadiumName varchar(20))
	RETURNS TABLE 
	AS
	RETURN 
		SELECT H.id,CR.name AS cr_name,host.name AS host_club, guest.name AS guest_club,Mat.start_time,Mat.end_time,H.status
		FROM Match Mat
			INNER JOIN Club host on Mat.host_id = host.id
			INNER JOIN Club guest on Mat.guest_id = guest.id
			INNER JOIN HostRequest H ON H.match_id = Mat.id
			INNER JOIN StadiumManager SM ON H.smd = SM.id 
			INNER JOIN ClubRepresentative CR ON CR.id = H.crd
			INNER JOIN Stadium S ON S.id = SM.stadium_id
		WHERE S.name = @stadiumName
GO;


GO;

CREATE View getMatches2 AS
	SELECT c1.name AS Host , c2.name AS Guest , M.start_time , M.end_time
	FROM Match M
	INNER JOIN Club c1 on M.host_id = c1.id
	INNER JOIN Club c2 on M.guest_id = c2.id

GO;

CREATE VIEW allStadiumsWithNoManagers AS
	SELECT S.name AS stadium_name
	FROM StadiumManager M
		RIGHT OUTER JOIN Stadium S ON S.id = M.stadium_id
	WHERE username IS NULL
GO;

CREATE VIEW allClubsWithNoRep AS
	SELECT C.name AS club_name
	From ClubRepresentative R
		RIGHT OUTER JOIN Club C ON C.id = R.club_id
	WHERE username IS NULL
GO;

CREATE PROC deleteMatchWithDateTime
	@namehostclub VARCHAR(20),
	@nameguestclub VARCHAR(20),	
	@startTime DATETIME
	AS

	DECLARE @host INT
	SELECT @host = C.id
	FROM Club C
	WHERE C.name = @namehostclub;

	DECLARE @guest INT
	SELECT @guest = C.id
	FROM Club C
	Where C.name = @nameguestclub;

	DELETE FROM HostRequest
	WHERE match_id IN (
		SELECT id
		FROM Match
		WHERE (Match.host_id = @host AND Match.guest_id = @guest AND Match.start_time=@startTime)
	);

	DELETE FROM Match 
	WHERE (Match.host_id = @host AND Match.guest_id = @guest AND Match.start_time=@startTime) 
GO;

CREATE PROC addHostRequest2 
	@clubName VARCHAR(20),
	@stadiumName VARCHAR(20),
	@startTime DATETIME
	AS 

	DECLARE @clubRepId INT;
	DECLARE @hostId INT;
	SELECT @clubRepId = CR.id, @hostId = C.id
	FROM ClubRepresentative CR
		INNER JOIN Club C on C.id = CR.club_id
	WHERE C.name = @clubName

	DECLARE @stadiumManagerId INT;
	SELECT @stadiumManagerId = SM.id
	FROM StadiumManager SM
		INNER JOIN Stadium S on S.id = SM.stadium_id
	WHERE S.name = @stadiumName

	DECLARE @matchId INT
	DECLARE @stadiumId INT
	SELECT @matchId = M.id, @stadiumId=M.stadium_id
	FROM Match M
	WHERE M.host_id = @hostId AND M.start_time = @startTime
	IF (@matchId IS NOT NULL AND @stadiumManagerId IS NOT NULL AND @clubRepId IS NOT NULL AND @stadiumId IS NULL AND @startTime>CURRENT_TIMESTAMP)
	BEGIN
		INSERT INTO HostRequest(match_id,smd,crd) VALUES (@matchId,@stadiumManagerId,@clubRepId);
	END
	ELSE 
	BEGIN
		PRINT 'One of entries is null as it was not found in the database'
	END
GO;

CREATE View getAlreadyPlayedMatches2 AS
	SELECT c1.name AS host_club_name , c2.name AS guest_club_name , M.start_time , M.end_time
	FROM Match M
	INNER JOIN Club c1 on M.host_id = c1.id
	INNER JOIN Club c2 on M.guest_id = c2.id
	WHERE M.end_time < CURRENT_TIMESTAMP;
GO;

CREATE View getUpcomingMatches2 AS
	SELECT c1.name AS host_club_name , c2.name AS guest_club_name , M.start_time , M.end_time
	FROM Match M
	INNER JOIN Club c1 on M.host_id = c1.id
	INNER JOIN Club c2 on M.guest_id = c2.id
	WHERE M.start_time > CURRENT_TIMESTAMP;
GO;

CREATE PROC upcomingMatchesOfClubWithNoStadium 
	@clubName VARCHAR(20)
	AS 
		SELECT C2.name AS competing_club_name,M.start_time
		FROM Match M 
			INNER JOIN Club C ON C.id = M.host_id
			INNER JOIN Club C2 on C2.id = M.guest_id
			LEFT OUTER JOIN Stadium S on S.id=M.stadium_id
		WHERE  (C.name = @clubName OR C2.name = @clubName) AND M.start_time> CURRENT_TIMESTAMP AND M.stadium_id IS NULL
GO;

CREATE VIEW allMatches2 AS
	SELECT C1.name AS host_club , C2.name AS guest_club , M.start_time, M.end_time
	FROM Match M
		INNER JOIN Club C1 ON C1.id = M.host_id 
		INNER JOIN Club C2 ON C2.id = M.guest_id; 
GO;