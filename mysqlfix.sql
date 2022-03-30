use goautodial;
ALTER TABLE go_campaigns ADD COLUMN auto_dial_level VARCHAR(20) DEFAULT 'NORMAL';
ALTER TABLE go_campaigns ADD COLUMN cb_noexpire TINYINT(1) DEFAULT '0';
ALTER TABLE go_campaigns ADD COLUMN cb_sendemail TINYINT(1) DEFAULT '0';
ALTER TABLE go_campaigns ADD COLUMN default_country_code VARCHAR(20) DEFAULT 'USA_1';
ALTER TABLE go_campaigns ADD COLUMN enable_callback_alert TINYINT(1) DEFAULT '0';
ALTER TABLE go_campaigns ADD COLUMN google_sheet_ids TEXT;
ALTER TABLE go_campaigns ADD COLUMN google_sheet_list_id BIGINT(14) UNSIGNED DEFAULT '0';
ALTER TABLE go_campaigns ADD COLUMN manual_dial_min_digits INT(11) DEFAULT '6';
ALTER TABLE users ADD COLUMN enable_chat tinyint(1) NULL DEFAULT '1';
ALTER TABLE users ADD COLUMN enable_webrtc tinyint(1)  DEFAULT '1';
use asterisk;
UPDATE system_settings SET agent_whisper_enabled='1';
UPDATE system_settings SET active_voicemail_server="127.0.0.1";