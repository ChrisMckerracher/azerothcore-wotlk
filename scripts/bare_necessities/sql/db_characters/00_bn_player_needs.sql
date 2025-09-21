CREATE TABLE IF NOT EXISTS `player_needs` (
  `ID` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Player Name, no FK since idk how this db handles fk',
  `Hunger` int NOT NULL DEFAULT '5' COMMENT 'More hunger meter = more satiated',
  `Thirst` int NOT NULL DEFAULT '5' COMMENT 'See Hunger comment',
  `Rest` int NOT NULL DEFAULT '5' COMMENT 'See Rest comment',
  `Damage` int NOT NULL DEFAULT '5' Comment 'More damage = less damaged. 0 Damage = most damaged',
  `DamageLegs` bool NOT NULL DEFAULT '0' COMMENT 'Affects walk speed',
  `DamageArms` bool NOT NULL DEFAULT '0' COMMENT 'Affects attack damage',
  `DamageHead` bool NOT NULL DEFAULT '0' COMMENT 'Affects aim',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
