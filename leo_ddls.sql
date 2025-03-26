IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[competitions]') and type = 'U')
 )
BEGIN
CREATE TABLE competitions (
    competition_id VARCHAR(10),
    competition_code VARCHAR(50),
    name VARCHAR(100),
    sub_type VARCHAR(50),
    type VARCHAR(50),
    country_id INT,
    country_name VARCHAR(50),
    domestic_league_code VARCHAR(10),
    confederation VARCHAR(50),
    url TEXT,
    is_major_national_league VARCHAR(50),
    partitionDate VARCHAR(8),
    PRIMARY KEY (competition_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[games]') and type = 'U')
 )
BEGIN
CREATE TABLE games (
    game_id INT,
    home_club_id INT,
    away_club_id INT,
    competition_id VARCHAR(10),
    season INT,
    round VARCHAR(50),
    date DATE,    
    home_club_goals INT,
    away_club_goals INT,
    home_club_position INT,
    away_club_position INT,
    home_club_manager_name VARCHAR(100),
    away_club_manager_name VARCHAR(100),
    stadium VARCHAR(100),
    attendance INT,
    referee VARCHAR(100),
    url TEXT,
    home_club_formation VARCHAR(50),
    away_club_formation VARCHAR(50),
    home_club_name VARCHAR(100),
    away_club_name VARCHAR(100),
    aggregate VARCHAR(20),
    competition_type VARCHAR(50),
    partitionDate VARCHAR(8),
    PRIMARY KEY (game_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[clubs]') and type = 'U')
 )
BEGIN
CREATE TABLE clubs (
    club_id INT,
    club_code VARCHAR(50),
    name VARCHAR(100),
    domestic_competition_id VARCHAR(10),
    total_market_value VARCHAR(50),
    squad_size INT,
    average_age DECIMAL(4,1),
    foreigners_number INT,
    foreigners_percentage DECIMAL(4,1),
    national_team_players INT,
    stadium_name VARCHAR(100),
    stadium_seats INT,
    net_transfer_record VARCHAR(50),
    coach_name VARCHAR(100),
    last_season INT,
    filename VARCHAR(200),
    url TEXT,
    partitionDate VARCHAR(8),
    PRIMARY KEY (club_id, domestic_competition_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[appearances]') and type = 'U')
 )
BEGIN
CREATE TABLE appearances (
    appearance_id VARCHAR(20),
    game_id INT,
    player_id INT,
    player_club_id INT,
    player_current_club_id INT,
    date DATE,
    player_name VARCHAR(100),
    competition_id VARCHAR(10),
    yellow_cards INT,
    red_cards INT,
    goals INT,
    assists INT,
    minutes_played INT,
    partitionDate VARCHAR(8),
    PRIMARY KEY (appearance_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[players]') and type = 'U')
 )
BEGIN
CREATE TABLE players (
  player_id INT,
  first_name VARCHAR(200),
  last_name VARCHAR(200),
  name VARCHAR(200),
  last_season INT,
  current_club_id INT,
  player_code VARCHAR(200),
  country_of_birth VARCHAR(200),
  city_of_birth VARCHAR(100),
  country_of_citizenship VARCHAR(200),
  date_of_birth DATE,
  sub_position VARCHAR(200),
  position VARCHAR(200),
  foot VARCHAR(200),
  height_in_cm INT,
  contract_expiration_date VARCHAR(200),
  agent_name VARCHAR(200),
  image_url text,
  url text,
  current_club_domestic_competition_id VARCHAR(200),
  current_club_name VARCHAR(200),
  market_value_in_eur INT,
  highest_market_value_in_eur INT,
  partitionDate VARCHAR(200),
  PRIMARY KEY (player_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[club_games]') and type = 'U')
 )
BEGIN
CREATE TABLE club_games (
    game_id INT,
    club_id INT,
    own_goals INT,
    own_position VARCHAR(50),
    own_manager_name VARCHAR(100),
    opponent_id INT,
    opponent_goals INT,
    opponent_position VARCHAR(50),
    opponent_manager_name VARCHAR(100),
    hosting VARCHAR(10),
    is_win VARCHAR(10),
    partitionDate VARCHAR(8),
    PRIMARY KEY (game_id, club_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[game_lineups]') and type = 'U')
 )
BEGIN
CREATE TABLE game_lineups (
    game_lineups_id VARCHAR(200),
    game_id INT,
    player_id INT,
    club_id INT,
    player_name VARCHAR(200),
    type VARCHAR(200),
    position VARCHAR(200),
    number VARCHAR(200),
    team_captain VARCHAR(200),
    date DATE,
    partitionDate VARCHAR(8),
    PRIMARY KEY (game_lineups_id, player_id, club_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[game_events]') and type = 'U')
 )
BEGIN
CREATE TABLE game_events (
    game_event_id VARCHAR(50),
    date DATE,
    game_id INT,
    minute INT,
    type VARCHAR(50),
    club_id INT,
    player_id INT,
    description TEXT,
    player_in_id INT,
    player_assist_id INT,
    partitionDate VARCHAR(8),
    PRIMARY KEY (game_event_id, player_id)
)
END;
IF 
 ( NOT EXISTS 
   (select object_id from sys.objects where object_id = OBJECT_ID(N'[dbo].[player_valuations]') and type = 'U')
 )
BEGIN
CREATE TABLE player_valuations (
    player_id INT,
    date DATE,
    market_value_in_eur INT,
    current_club_id INT,
    player_club_domestic_competition_id VARCHAR(10),
    partitionDate VARCHAR(8),
    PRIMARY KEY (player_id, date)
)
END;