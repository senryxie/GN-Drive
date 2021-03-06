DROP TABLE IF EXISTS `sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sid` bigint(16) unsigned NOT NULL,
  `pic` varchar(64) NOT NULL DEFAULT '',
  `snum` int(10) unsigned NOT NULL DEFAULT '0',
  `lnum` int(10) unsigned NOT NULL DEFAULT '0',
  `author` bigint(16) unsigned NOT NULL DEFAULT '0',
  `text` varchar(500) CHARACTER SET ucs2 NOT NULL DEFAULT '',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sid` (`sid`),
  KEY `idx_time_lnum_snum` (`create_time`,`lnum`,`snum`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1 COMMENT='训练数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entry`
--

DROP TABLE IF EXISTS `entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entry` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sid` bigint(16) unsigned NOT NULL,
  `pic` varchar(64) NOT NULL DEFAULT '',
  `snum` int(10) unsigned NOT NULL DEFAULT '0',
  `lnum` int(10) unsigned NOT NULL DEFAULT '0',
  `author` bigint(16) unsigned NOT NULL DEFAULT '0',
  `text` varchar(500) CHARACTER SET ucs2 NOT NULL DEFAULT '',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sid` (`sid`),
  KEY `idx_time_lnum_snum` (`create_time`,`lnum`,`snum`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1 COMMENT='条目表/2012-05-24';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `draft`
--

DROP TABLE IF EXISTS `draft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `draft` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sid` bigint(16) unsigned NOT NULL,
  `pic` varchar(64) NOT NULL DEFAULT '',
  `snum` int(10) unsigned NOT NULL DEFAULT '0',
  `lnum` int(10) unsigned NOT NULL DEFAULT '0',
  `author` bigint(16) unsigned NOT NULL DEFAULT '0',
  `text` varchar(500) CHARACTER SET ucs2 NOT NULL DEFAULT '',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sid` (`sid`),
  KEY `idx_time_lnum_snum` (`create_time`,`lnum`,`snum`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1 COMMENT='候选池/2012-05-24';
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `device` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `udid` varchar(40) DEFAULT NULL,
  `start` int(16) unsigned NOT NULL,
  `end` int(16) unsigned NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `udid` (`udid`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='用户设备表/2012-03-15' AUTO_INCREMENT=216331 ;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE IF NOT EXISTS `features` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `word` varchar(40) CHARACTER SET ucs2 NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 COMMENT='特征表/2012-06-07';
/*!40101 SET character_set_client = @saved_cs_client */;
