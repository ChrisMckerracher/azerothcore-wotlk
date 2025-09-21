CREATE TABLE IF NOT EXISTS `player_sub_class` (
  `ID` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Player Name, no FK since idk how this db handles fk',
  `SubClass` varchar(255) NULL COMMENT 'Subclass, not enum based, to keep extension purely in lua'
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
