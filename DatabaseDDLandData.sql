CREATE TABLE practice (
    practice_name character varying(200) NOT NULL,
    website character varying(200),
    phone numeric(10,0),
    street_number numeric,
    street_name character varying(50),
    suite character varying(50),
    city character varying(100),
    state character(2),
    zip numeric(5,0),
    PRIMARY KEY (practice_name)
);


CREATE TABLE provider (
    license_number character varying(20) NOT NULL,
    first_name character varying(30),
    middle_name character varying(30),
    last_name character varying(30),
    PRIMARY KEY (license_number)
);


CREATE TABLE reviews (
    id numeric(10,0) NOT NULL,
    review_text character varying(50000),
    rating_overall numeric(1,0),
    rating_expertise numeric(1,0),
    rating_listening numeric(1,0),
    CONSTRAINT reviews_rating_expertise_check CHECK (((rating_expertise <= (5)) AND (rating_expertise > (0)))),
    CONSTRAINT reviews_rating_listening_check CHECK (((rating_listening <= (5)) AND (rating_listening > (0)))),
    CONSTRAINT reviews_rating_overall_check CHECK (((rating_overall <= (5)) AND (rating_overall > (0)))),
    PRIMARY KEY (id)
);


CREATE TABLE specialties (
    specialty character varying(100) NOT NULL,
    PRIMARY KEY (specialty)
);


CREATE TABLE insurance (
    insurer_name character varying(200) NOT NULL,
    PRIMARY KEY (insurer_name)
);


CREATE TABLE posted_to (
    license_number character varying(20) NOT NULL,
    id numeric(10,0) NOT NULL,
    PRIMARY KEY (license_number, id),
    FOREIGN KEY (id) REFERENCES reviews(id) ON UPDATE CASCADE,
    FOREIGN KEY (license_number) REFERENCES provider(license_number) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE certified_as (
    license_number character varying(20) NOT NULL,
    specialty character varying(100) NOT NULL,
    PRIMARY KEY (license_number, specialty),
    FOREIGN KEY (license_number) REFERENCES provider(license_number) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (specialty) REFERENCES specialties(specialty) ON UPDATE CASCADE
);


CREATE TABLE takes (
    license_number character varying(20) NOT NULL,
    insurer_name character varying(200) NOT NULL,
    PRIMARY KEY (license_number, insurer_name),
    FOREIGN KEY (insurer_name) REFERENCES insurance(insurer_name) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (license_number) REFERENCES provider(license_number) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE works_at (
    license_number character varying(20) NOT NULL,
    practice_name character varying(200) NOT NULL,
    PRIMARY KEY (license_number, practice_name),
    FOREIGN KEY (license_number) REFERENCES provider(license_number) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (practice_name) REFERENCES practice(practice_name) ON UPDATE CASCADE
);

INSERT INTO insurance VALUES ('Aetna');
INSERT INTO insurance VALUES ('Aetna - Elect Choice');
INSERT INTO insurance VALUES ('Aetna - HMO');
INSERT INTO insurance VALUES ('Aetna - Open Access Elect Choice');
INSERT INTO insurance VALUES ('Aetna - Open Access HMO');
INSERT INTO insurance VALUES ('Aetna - Open Access Managed Choice');
INSERT INTO insurance VALUES ('Aetna - Open Choice PPO');
INSERT INTO insurance VALUES ('Aetna - QPOS');
INSERT INTO insurance VALUES ('Aetna - US Access');
INSERT INTO insurance VALUES ('Aetna Choice POS II');
INSERT INTO insurance VALUES ('Aetna HMO');
INSERT INTO insurance VALUES ('Aetna Managed Choice POS Open Access');
INSERT INTO insurance VALUES ('Aetna Signature Administrators PPO');
INSERT INTO insurance VALUES ('Aexcel PPO');
INSERT INTO insurance VALUES ('Ambetter from Superior HealthPlan MRF');
INSERT INTO insurance VALUES ('Ambetter Superior Health Plan');
INSERT INTO insurance VALUES ('Anthem Blue Cross');
INSERT INTO insurance VALUES ('Anthem Blue Cross Blue Shield');
INSERT INTO insurance VALUES ('APWU');
INSERT INTO insurance VALUES ('Arkansas Blue Cross Blue Shield');
INSERT INTO insurance VALUES ('Assurant Health');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Access PPO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Extended PPO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Plus HMO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Plus PPO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Preferred EPO Network');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Preferred HMO - Individual Marketplace');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Preferred HMO Network - Group');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW Preferred PPO Network');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW SeniorCare Advantage HMO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSW SeniorCare Advantage PPO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSWH Employee Network - PPO & HSA');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - BSWH Employee Network - SEQA & EQA');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - Covenant Preferred HMO');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - EPO Network-Group');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - EPO Network-Individual/Family');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - ERS BSW Preferred HMO Network');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - Hendrick Health Employee Plan');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - HMO Network-Group');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - HMO Network-Individual/Family');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - McLane Group Network');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - PPO Choice Network');
INSERT INTO insurance VALUES ('Baylor Scott & White Health Plan - PPO Network-Group');
INSERT INTO insurance VALUES ('BCBS Blue Card PPO');
INSERT INTO insurance VALUES ('BCBS California CaliforniaCare HMO');
INSERT INTO insurance VALUES ('BCBS California PowerSelect HMO');
INSERT INTO insurance VALUES ('BCBS California PPO');
INSERT INTO insurance VALUES ('BCBS Texas BlueChoice');
INSERT INTO insurance VALUES ('BCBS TX Blue Advantage HMO');
INSERT INTO insurance VALUES ('BCBS TX BlueChoice');
INSERT INTO insurance VALUES ('BCBS TX HMO Blue Texas');
INSERT INTO insurance VALUES ('Beech Street');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Arizona');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Georgia');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Illinois');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Kansas');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Kansas City');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Louisiana');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Massachusetts');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Michigan');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Minnesota');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Nebraska');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of New Mexico');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of North Carolina');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Rhode Island');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of South Carolina');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Texas');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Vermont');
INSERT INTO insurance VALUES ('Blue Cross Blue Shield of Wyoming');
INSERT INTO insurance VALUES ('Blue Cross of Idaho');
INSERT INTO insurance VALUES ('Blue Cross of Northeastern Pennsylvania');
INSERT INTO insurance VALUES ('Blue Essentials HMO');
INSERT INTO insurance VALUES ('Blue Shield CA Local Access Plus HMO');
INSERT INTO insurance VALUES ('Blue Shield California HMO');
INSERT INTO insurance VALUES ('Blue Shield California PPO');
INSERT INTO insurance VALUES ('Blue Shield of California');
INSERT INTO insurance VALUES ('Blue Shield of Northeastern New York');
INSERT INTO insurance VALUES ('Capital Blue Cross');
INSERT INTO insurance VALUES ('CareFirst Blue Cross Blue Shield (Health)');
INSERT INTO insurance VALUES ('Caterpillar');
INSERT INTO insurance VALUES ('CBA Blue');
INSERT INTO insurance VALUES ('Cigna');
INSERT INTO insurance VALUES ('CIGNA HMO');
INSERT INTO insurance VALUES ('CIGNA LocalPlus');
INSERT INTO insurance VALUES ('CIGNA Open Access');
INSERT INTO insurance VALUES ('CIGNA Open Access Plus');
INSERT INTO insurance VALUES ('CIGNA PPO');
INSERT INTO insurance VALUES ('Consolidated Health Plans');
INSERT INTO insurance VALUES ('Coventry Health Care');
INSERT INTO insurance VALUES ('Empire Blue Cross Blue Shield (Health)');
INSERT INTO insurance VALUES ('First Health PPO');
INSERT INTO insurance VALUES ('Florida Blue: Blue Cross Blue Shield of Florida');
INSERT INTO insurance VALUES ('GEHA');
INSERT INTO insurance VALUES ('GeoBlue');
INSERT INTO insurance VALUES ('Great West PPO');
INSERT INTO insurance VALUES ('Guardian');
INSERT INTO insurance VALUES ('GWH-Cigna (formerly Great West Healthcare)');
INSERT INTO insurance VALUES ('Harvard Pilgrim Health Care');
INSERT INTO insurance VALUES ('Health Net California Large Group PPO');
INSERT INTO insurance VALUES ('HealthSmart');
INSERT INTO insurance VALUES ('Highmark Blue Cross Blue Shield');
INSERT INTO insurance VALUES ('Highmark Blue Cross Blue Shield of Delaware');
INSERT INTO insurance VALUES ('Highmark Blue Shield');
INSERT INTO insurance VALUES ('Horizon Blue Cross Blue Shield of New Jersey');
INSERT INTO insurance VALUES ('Humana');
INSERT INTO insurance VALUES ('Humana Choice POS');
INSERT INTO insurance VALUES ('Humana ChoiceCare Network PPO');
INSERT INTO insurance VALUES ('Humana National POS');
INSERT INTO insurance VALUES ('Humana Preferred PPO');
INSERT INTO insurance VALUES ('Imagine Health SmartCare');
INSERT INTO insurance VALUES ('Independence Blue Cross');
INSERT INTO insurance VALUES ('Mail Handlers Benefit Plan');
INSERT INTO insurance VALUES ('MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO insurance VALUES ('Memorial Hermann');
INSERT INTO insurance VALUES ('Molina place TX');
INSERT INTO insurance VALUES ('Multiplan PHCS');
INSERT INTO insurance VALUES ('Multiplan PHCS PPO');
INSERT INTO insurance VALUES ('Multiplan PHCS PPO - Kaiser');
INSERT INTO insurance VALUES ('Multiplan PPO');
INSERT INTO insurance VALUES ('MyBlue Health HMO');
INSERT INTO insurance VALUES ('Oscar Insurance TX');
INSERT INTO insurance VALUES ('Oxford (UnitedHealthcare)');
INSERT INTO insurance VALUES ('Pacificare HMO');
INSERT INTO insurance VALUES ('PHCS PPO');
INSERT INTO insurance VALUES ('Premera Blue Cross');
INSERT INTO insurance VALUES ('Principal Financial Group');
INSERT INTO insurance VALUES ('Regence Blue Cross Blue Shield');
INSERT INTO insurance VALUES ('Scott and White PPO');
INSERT INTO insurance VALUES ('Triple-S Salud: Blue Cross Blue Shield of Puerto Rico');
INSERT INTO insurance VALUES ('TX Ambetter');
INSERT INTO insurance VALUES ('UHC Choice Plus POS');
INSERT INTO insurance VALUES ('UHC Navigate HMO');
INSERT INTO insurance VALUES ('UHC NAVIGATE PLUS POS');
INSERT INTO insurance VALUES ('UHC Navigate POS');
INSERT INTO insurance VALUES ('UHC Options PPO');
INSERT INTO insurance VALUES ('UniCare');
INSERT INTO insurance VALUES ('United Healthcare - Direct Choice Plus POS');
INSERT INTO insurance VALUES ('United Healthcare - Direct Options PPO');
INSERT INTO insurance VALUES ('UnitedHealthcare');
INSERT INTO insurance VALUES ('UnitedHealthcare Oxford');
INSERT INTO insurance VALUES ('UnitedHealthOne');
INSERT INTO insurance VALUES ('Wellmark Blue Cross Blue Shield');



INSERT INTO practice VALUES ('American Institute for Plastic Survery', 'https://www.ai4ps.com/plano-plastic-surgeons/dr-peter-raphael/', 9725432477, 6020, 'W Plano Pkwy', NULL, 'Plano', 'TX', 75093);
INSERT INTO practice VALUES ('Baylor Scott & White Women''s Health Group', 'https://www.bswhealth.com/physician/uchechi-anumudu', 4698009290, 3600, 'Gaston Ave', 'Wadley Tower, Ste 1158', 'Dallas', 'TX', 75246);
INSERT INTO practice VALUES ('Dallas Family Medicine', 'http://www.dallasfamilymed.com/', 2143494909, 8668, 'Skillman Street', NULL, 'Dallas', 'TX', 75243);
INSERT INTO practice VALUES ('Diabetes and Endocrinology Clinical Consultants of Texas', 'https://diabetesendotx.com/', 2146602020, 12606, 'Greenville Ave', '#215', 'Dallas', 'TX', 75243);
INSERT INTO practice VALUES ('Dr. Aimee Wright', 'https://www.draimeewright.com/', 9724243333, 428, 'Maplelawn ', 'Suite 200', 'Plano', 'TX', 75075);
INSERT INTO practice VALUES ('Dr. David Feinstein', 'http://drdavidf.com/', 2149640860, 5232, 'Forest Lane', 'Suite 170', 'Dallas', 'TX', 75244);
INSERT INTO practice VALUES ('Dr. Renee Baker', 'http://renee-baker.com/', 2146075620, 13500, 'Midway Road', '#404', 'Dallas', 'TX', 75244);
INSERT INTO practice VALUES ('Dr. Ronald Giometti', 'https://www.ronaldgiomettimd.com/', 9723949478, 4325, 'N Josey Lane', 'Suite 105', 'Carrollton', 'TX', 75010);
INSERT INTO practice VALUES ('Dr. Steven Pounders', 'https://drpounders.com/', 2145208833, 3500, 'Oak Lawn Ave', 'Unit 600', 'Dallas', 'TX', 75219);
INSERT INTO practice VALUES ('Dr. Stockton Roberts', NULL, 9729423410, 3310, 'Live Oak St', NULL, 'Dallas', 'TX', 75204);
INSERT INTO practice VALUES ('Dr. Terry Watson', 'https://dr-terry-r-watson-do-p-a.business.site/', 2142218181, 8204, 'Elmbrook Drive', '#206', 'Dallas', 'TX', 75247);
INSERT INTO practice VALUES ('Endocrine and Thyroid Center', 'https://etcdocs.com/', 8174109993, 7141, 'Colleyville Blvd', NULL, 'Colleyville', 'TX', 76034);
INSERT INTO practice VALUES ('Endocrine Associates of Dallas', 'https://endocrineassociatesdallas.com/jaime-l-wiebel-md/', 2143635535, 10260, 'North Central Expressway', 'Suite 100N', 'Dallas', 'TX', 75231);
INSERT INTO practice VALUES ('HealthCore Physicians Group', 'https://www.healthcoreweb.com/', 9722847000, 8210, 'Walnut Hill Lane', 'Suite 230', 'Dallas', 'TX', 75231);
INSERT INTO practice VALUES ('Methodist Health Center - Oak Lawn', 'https://www.methodisthealthsystem.org/doctors/blake-hatfield-md/#~J0V0M43', 2145263566, 3500, 'Maple Avenue', 'Suite 108', 'Dallas', 'TX', 75219);
INSERT INTO practice VALUES ('Ronald Giometti', 'https://www.ronaldgiomettimd.com/', 9723949478, 4325, 'N Josey Lane', 'Suite 105', 'Carrollton', 'TX', 75010);
INSERT INTO practice VALUES ('Southern Endocrinology and Diabetes Associates', 'https://www.southernendocrinology.com/', 9726825700, 161, 'N Belt Line Road', '#A', 'Mesquite', 'TX', 75149);
INSERT INTO practice VALUES ('Southwest Family Medicine', 'https://www.southwestfamilymed.com/contactus', 2143932940, 8877, 'Harry Hines Boulevard', NULL, 'Dallas', 'TX', 75235);
INSERT INTO practice VALUES ('Thyroid Endocrinology and Diabetes', 'https://www.tedclinic.org/', 9728838092, 1018, 'N Zang Blvd', 'Suite 110', 'Dallas', 'TX', 75208);
INSERT INTO practice VALUES ('Transcend Medical Group', 'https://www.txphysicians.com/the-practice', 8178602700, 2206, 'W Park Row Drive', 'Suite 102', 'Pantego', 'TX', 76013);
INSERT INTO practice VALUES ('Uptown Physicians Group', 'https://www.uptownphysiciansgroup.com/', 2143031033, 2801, 'Lemmon Ave', '#400', 'Dallas', 'TX', 75204);
INSERT INTO practice VALUES ('UT Southwestern Medical Center', 'https://utswmed.org/doctors/jessica-abramowitz/#map-widget', 2146452800, 2001, 'Inwood Road', '8th Floor', 'Dallas', 'TX', 75290);
INSERT INTO practice VALUES ('Baylor Scott & White Family Medical Center - North Garland', 'https://www.bswhealth.com/locations/family-medical-center-north-garland', 4698002100, 7217, 'Telecom Pkwy', 'Ste 100', 'Garland', 'TX', 75044);


INSERT INTO provider VALUES ('Q5315', 'Jessica', NULL, 'Abramowitz');
INSERT INTO provider VALUES ('Q1081', 'Sarah', 'Ogbedei', 'Ashitey');
INSERT INTO provider VALUES ('F0999', 'David', 'Manuel', 'Feinstein');
INSERT INTO provider VALUES ('R7018', 'Blake', NULL, 'Hatfield');
INSERT INTO provider VALUES ('K9285', 'Ronald', 'Peter', 'Giometti Jr');
INSERT INTO provider VALUES ('M4788', 'Sumana', NULL, 'Gangi');
INSERT INTO provider VALUES ('L0853', 'David', 'Michael', 'Lee');
INSERT INTO provider VALUES ('AP124414', 'Peter', NULL, 'Triporo');
INSERT INTO provider VALUES ('H0732', 'Steven', 'Marlo', 'Pounders');
INSERT INTO provider VALUES ('K8967', 'Henry', 'Michael', 'Prost');
INSERT INTO provider VALUES ('N7080', 'Erin', 'Dunnigan', 'Roe');
INSERT INTO provider VALUES ('J0224', 'Stockton', 'Edward', 'Roberts');
INSERT INTO provider VALUES ('G4949', 'Patrick', 'William', 'Daly');
INSERT INTO provider VALUES ('F1999', 'William', 'Robert', 'Sheldon ');
INSERT INTO provider VALUES ('M2140', 'Magdalene', 'Maria', 'Szuskiewicz-Garcia');
INSERT INTO provider VALUES ('F3376', 'Terry', NULL, 'Watson');
INSERT INTO provider VALUES ('Q3615', 'Jaime', 'Lauren', 'Wiebel');
INSERT INTO provider VALUES ('L3879', 'Randall ', 'Morris', 'Wooley');
INSERT INTO provider VALUES ('F7329', 'Paul ', 'Stephen', 'Worrell');
INSERT INTO provider VALUES ('L1500', 'Aimee', 'Lou', 'Wright');
INSERT INTO provider VALUES ('70441', 'Renee', 'S.', 'Baker');
INSERT INTO provider VALUES ('G8361', 'Peter', NULL, 'Raphael');
INSERT INTO provider VALUES ('R0531', 'Uchechi ', 'B.', 'Anumudu');
INSERT INTO provider VALUES ('S2055', 'Alicia', 'Jean', 'Harbison');
INSERT INTO provider VALUES ('L8664', 'April', 'Marie', 'Day');


INSERT INTO reviews VALUES (10000, 'I like that Dr. Roe prescribed me Progesterone without really fighting me on it. I also really liked how she called and left me a voicemail after recently attended a conference to give me an update on what recent research said about effects of Progesterone for breast growth. I do feel like she mostly knows her stuff, although she was not very receptive to me asking about things I had heard about online. I don''t considered that a red flag really, though. I disliked how she would bring up things she assumed I would be doing for my transition. Almost every visit she asked why I hadn''t started voice therapy, and would encourage me to start. One time I told her I got a new job, and that I would be out from the start their. Her first response was to ask whether I was going to change my name for the job or not. She also commented on my weight each time I went. I felt as though she didn''t really believe me when I said that I ate healthy and often. She always wanted me to gain more weight. Overall, my experience with her was a bit of a mixed bag. I appreciate her expertise, and her technical explanations of things. I do think she stays up-to-date on trans healthcare, which alone is a pretty big win in Dallas. I did decide to stop seeing her, as the comments about my voice, weight, and name started to feel like judgment over time.', 3, 4, 4);
INSERT INTO reviews VALUES (10002, 'I found the staff here to be very respectful of my name on the forms, even when they dont match up with my ''legal name''. Dr Day doesnt seem to prescribe hrt, but otherwise very affirming care', 4, 4, 5);
INSERT INTO reviews VALUES (10001, 'She''s a great doctor in terms of not being fatphobic, but I have to remind her of my pronouns. Once I remind her, she''s good, but its everytime, and sometimes like if its just a checkup I don''t bother.', 4, 3, 3);


INSERT INTO specialties VALUES ('Family Medicine');
INSERT INTO specialties VALUES ('Endocrinology');
INSERT INTO specialties VALUES ('Internal Medicine');
INSERT INTO specialties VALUES ('Advanced Practice Nurse');
INSERT INTO specialties VALUES ('General Practice');
INSERT INTO specialties VALUES ('Licensed Professional Counselor');
INSERT INTO specialties VALUES ('Plastic Surgery');
INSERT INTO specialties VALUES ('Obstretrics and Gynecology');


INSERT INTO takes VALUES ('J0224', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('J0224', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('J0224', 'CIGNA HMO');
INSERT INTO takes VALUES ('J0224', 'CIGNA PPO');
INSERT INTO takes VALUES ('J0224', 'Great West PPO');
INSERT INTO takes VALUES ('J0224', 'Multiplan PHCS PPO');
INSERT INTO takes VALUES ('J0224', 'United Healthcare - Direct Choice Plus POS');
INSERT INTO takes VALUES ('J0224', 'Aetna HMO');
INSERT INTO takes VALUES ('J0224', 'BCBS Texas BlueChoice');
INSERT INTO takes VALUES ('J0224', 'CIGNA Open Access');
INSERT INTO takes VALUES ('J0224', 'First Health PPO');
INSERT INTO takes VALUES ('J0224', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('J0224', 'Multiplan PPO');
INSERT INTO takes VALUES ('J0224', 'United Healthcare - Direct Options PPO');
INSERT INTO takes VALUES ('N7080', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('N7080', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('N7080', 'CIGNA Open Access');
INSERT INTO takes VALUES ('N7080', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('N7080', 'United Healthcare - Direct Choice Plus POS');
INSERT INTO takes VALUES ('N7080', 'Aetna HMO');
INSERT INTO takes VALUES ('N7080', 'BCBS Texas BlueChoice');
INSERT INTO takes VALUES ('N7080', 'CIGNA PPO');
INSERT INTO takes VALUES ('N7080', 'Multiplan PHCS PPO');
INSERT INTO takes VALUES ('N7080', 'United Healthcare - Direct Options PPO');
INSERT INTO takes VALUES ('G4949', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('G4949', 'CIGNA Open Access Plus');
INSERT INTO takes VALUES ('G4949', 'UHC Options PPO');
INSERT INTO takes VALUES ('G4949', 'CIGNA LocalPlus');
INSERT INTO takes VALUES ('G4949', 'Humana National POS');
INSERT INTO takes VALUES ('G4949', 'UHC Choice Plus POS');
INSERT INTO takes VALUES ('G4949', 'Aetna Managed Choice POS Open Access');
INSERT INTO takes VALUES ('G4949', 'First Health PPO');
INSERT INTO takes VALUES ('G4949', 'Aetna HMO');
INSERT INTO takes VALUES ('G4949', 'Humana Preferred PPO');
INSERT INTO takes VALUES ('G4949', 'UHC Navigate POS');
INSERT INTO takes VALUES ('G4949', 'Humana Choice POS');
INSERT INTO takes VALUES ('G4949', 'BCBS TX BlueChoice');
INSERT INTO takes VALUES ('G4949', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('G4949', 'CIGNA HMO');
INSERT INTO takes VALUES ('G4949', 'PHCS PPO');
INSERT INTO takes VALUES ('G4949', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('G4949', 'Multiplan PPO');
INSERT INTO takes VALUES ('G4949', 'UHC Navigate HMO');
INSERT INTO takes VALUES ('G4949', 'CIGNA PPO');
INSERT INTO takes VALUES ('G4949', 'Scott and White PPO');
INSERT INTO takes VALUES ('G4949', 'BCBS TX Blue Advantage HMO');
INSERT INTO takes VALUES ('G4949', 'Aexcel PPO');
INSERT INTO takes VALUES ('G4949', 'Blue Essentials HMO');
INSERT INTO takes VALUES ('G4949', 'MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO takes VALUES ('G4949', 'Molina place TX');
INSERT INTO takes VALUES ('G4949', 'MyBlue Health HMO');
INSERT INTO takes VALUES ('G4949', 'Oscar Insurance TX');
INSERT INTO takes VALUES ('G4949', 'UHC NAVIGATE PLUS POS');
INSERT INTO takes VALUES ('G4949', 'Aetna Signature Administrators PPO');
INSERT INTO takes VALUES ('F7329', 'APWU');
INSERT INTO takes VALUES ('F7329', 'Aetna');
INSERT INTO takes VALUES ('F7329', 'Anthem Blue Cross');
INSERT INTO takes VALUES ('F7329', 'Anthem Blue Cross Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Arkansas Blue Cross Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Assurant Health');
INSERT INTO takes VALUES ('F7329', 'Beech Street');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Arizona');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Georgia');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Illinois');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Kansas');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Kansas City');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Louisiana');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Massachusetts');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Michigan');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Minnesota');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Nebraska');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of New Mexico');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of North Carolina');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Rhode Island');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of South Carolina');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Texas');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Vermont');
INSERT INTO takes VALUES ('F7329', 'Blue Cross Blue Shield of Wyoming');
INSERT INTO takes VALUES ('F7329', 'Blue Cross of Idaho');
INSERT INTO takes VALUES ('F7329', 'Blue Cross of Northeastern Pennsylvania');
INSERT INTO takes VALUES ('F7329', 'Blue Shield of California');
INSERT INTO takes VALUES ('F7329', 'Blue Shield of Northeastern New York');
INSERT INTO takes VALUES ('F7329', 'CBA Blue');
INSERT INTO takes VALUES ('F7329', 'Capital Blue Cross');
INSERT INTO takes VALUES ('F7329', 'CareFirst Blue Cross Blue Shield (Health)');
INSERT INTO takes VALUES ('F7329', 'Caterpillar');
INSERT INTO takes VALUES ('F7329', 'Cigna');
INSERT INTO takes VALUES ('F7329', 'Consolidated Health Plans');
INSERT INTO takes VALUES ('F7329', 'Coventry Health Care');
INSERT INTO takes VALUES ('F7329', 'Empire Blue Cross Blue Shield (Health)');
INSERT INTO takes VALUES ('F7329', 'Florida Blue: Blue Cross Blue Shield of Florida');
INSERT INTO takes VALUES ('F7329', 'GEHA');
INSERT INTO takes VALUES ('F7329', 'GWH-Cigna (formerly Great West Healthcare)');
INSERT INTO takes VALUES ('F7329', 'GeoBlue');
INSERT INTO takes VALUES ('F7329', 'Guardian');
INSERT INTO takes VALUES ('F7329', 'Harvard Pilgrim Health Care');
INSERT INTO takes VALUES ('F7329', 'HealthSmart');
INSERT INTO takes VALUES ('F7329', 'Highmark Blue Cross Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Highmark Blue Cross Blue Shield of Delaware');
INSERT INTO takes VALUES ('F7329', 'Highmark Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Horizon Blue Cross Blue Shield of New Jersey');
INSERT INTO takes VALUES ('F7329', 'Humana');
INSERT INTO takes VALUES ('F7329', 'Independence Blue Cross');
INSERT INTO takes VALUES ('F7329', 'Mail Handlers Benefit Plan');
INSERT INTO takes VALUES ('F7329', 'Memorial Hermann');
INSERT INTO takes VALUES ('F7329', 'Multiplan PHCS');
INSERT INTO takes VALUES ('F7329', 'Oxford (UnitedHealthcare)');
INSERT INTO takes VALUES ('F7329', 'Premera Blue Cross');
INSERT INTO takes VALUES ('F7329', 'Principal Financial Group');
INSERT INTO takes VALUES ('F7329', 'Regence Blue Cross Blue Shield');
INSERT INTO takes VALUES ('F7329', 'Triple-S Salud: Blue Cross Blue Shield of Puerto Rico');
INSERT INTO takes VALUES ('F7329', 'UniCare');
INSERT INTO takes VALUES ('F7329', 'UnitedHealthOne');
INSERT INTO takes VALUES ('F7329', 'UnitedHealthcare');
INSERT INTO takes VALUES ('F7329', 'UnitedHealthcare Oxford');
INSERT INTO takes VALUES ('F7329', 'Wellmark Blue Cross Blue Shield');
INSERT INTO takes VALUES ('R0531', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('R0531', 'CIGNA PPO');
INSERT INTO takes VALUES ('R0531', 'CIGNA Open Access Plus');
INSERT INTO takes VALUES ('R0531', 'CIGNA HMO');
INSERT INTO takes VALUES ('R0531', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('R0531', 'Aetna HMO');
INSERT INTO takes VALUES ('R0531', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('R0531', 'First Health PPO');
INSERT INTO takes VALUES ('R0531', 'UHC Choice Plus POS');
INSERT INTO takes VALUES ('R0531', 'UHC Options PPO');
INSERT INTO takes VALUES ('R0531', 'BCBS TX BlueChoice');
INSERT INTO takes VALUES ('R0531', 'Scott and White PPO');
INSERT INTO takes VALUES ('R0531', 'Humana National POS');
INSERT INTO takes VALUES ('R0531', 'Aetna Managed Choice POS Open Access');
INSERT INTO takes VALUES ('R0531', 'UHC Navigate HMO');
INSERT INTO takes VALUES ('R0531', 'CIGNA LocalPlus');
INSERT INTO takes VALUES ('R0531', 'Humana Choice POS');
INSERT INTO takes VALUES ('R0531', 'Humana Preferred PPO');
INSERT INTO takes VALUES ('R0531', 'BCBS TX Blue Advantage HMO');
INSERT INTO takes VALUES ('R0531', 'Ambetter Superior Health Plan');
INSERT INTO takes VALUES ('R0531', 'Imagine Health SmartCare');
INSERT INTO takes VALUES ('R0531', 'Blue Essentials HMO');
INSERT INTO takes VALUES ('R0531', 'MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO takes VALUES ('R0531', 'TX Ambetter');
INSERT INTO takes VALUES ('R0531', 'UHC NAVIGATE PLUS POS');
INSERT INTO takes VALUES ('S2055', 'CIGNA PPO');
INSERT INTO takes VALUES ('S2055', 'CIGNA Open Access Plus');
INSERT INTO takes VALUES ('S2055', 'CIGNA HMO');
INSERT INTO takes VALUES ('S2055', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('S2055', 'Aetna HMO');
INSERT INTO takes VALUES ('S2055', 'Multiplan PPO');
INSERT INTO takes VALUES ('S2055', 'First Health PPO');
INSERT INTO takes VALUES ('S2055', 'UHC Choice Plus POS');
INSERT INTO takes VALUES ('S2055', 'UHC Options PPO');
INSERT INTO takes VALUES ('S2055', 'PHCS PPO');
INSERT INTO takes VALUES ('S2055', 'Aetna Managed Choice POS Open Access');
INSERT INTO takes VALUES ('S2055', 'UHC Navigate HMO');
INSERT INTO takes VALUES ('S2055', 'CIGNA LocalPlus');
INSERT INTO takes VALUES ('S2055', 'Aexcel PPO');
INSERT INTO takes VALUES ('S2055', 'MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO takes VALUES ('S2055', 'UHC NAVIGATE PLUS POS');
INSERT INTO takes VALUES ('L8664', 'Aetna - Elect Choice');
INSERT INTO takes VALUES ('L8664', 'Aetna - HMO');
INSERT INTO takes VALUES ('L8664', 'Aetna - Open Access Elect Choice');
INSERT INTO takes VALUES ('L8664', 'Aetna - Open Access HMO');
INSERT INTO takes VALUES ('L8664', 'Aetna - Open Access Managed Choice');
INSERT INTO takes VALUES ('L8664', 'Aetna - Open Choice PPO');
INSERT INTO takes VALUES ('L8664', 'Aetna - QPOS');
INSERT INTO takes VALUES ('L8664', 'Aetna - US Access');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Access PPO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Extended PPO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Plus HMO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Plus PPO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Preferred EPO Network');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Preferred HMO - Individual Marketplace');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Preferred HMO Network - Group');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW Preferred PPO Network');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW SeniorCare Advantage HMO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSW SeniorCare Advantage PPO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSWH Employee Network - PPO & HSA');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - BSWH Employee Network - SEQA & EQA');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - Covenant Preferred HMO');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - EPO Network-Group');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - EPO Network-Individual/Family');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - ERS BSW Preferred HMO Network');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - Hendrick Health Employee Plan');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - HMO Network-Group');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - HMO Network-Individual/Family');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - McLane Group Network');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - PPO Choice Network');
INSERT INTO takes VALUES ('L8664', 'Baylor Scott & White Health Plan - PPO Network-Group');
INSERT INTO takes VALUES ('L1500', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('L1500', 'Aetna HMO');
INSERT INTO takes VALUES ('L1500', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('L1500', 'BCBS Texas BlueChoice');
INSERT INTO takes VALUES ('L1500', 'CIGNA HMO');
INSERT INTO takes VALUES ('L1500', 'CIGNA Open Access');
INSERT INTO takes VALUES ('L1500', 'CIGNA PPO');
INSERT INTO takes VALUES ('L1500', 'First Health PPO');
INSERT INTO takes VALUES ('L1500', 'Great West PPO');
INSERT INTO takes VALUES ('L1500', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('L1500', 'Multiplan PHCS PPO');
INSERT INTO takes VALUES ('L1500', 'Multiplan PPO');
INSERT INTO takes VALUES ('L1500', 'United Healthcare - Direct Choice Plus POS');
INSERT INTO takes VALUES ('L1500', 'United Healthcare - Direct Options PPO');
INSERT INTO takes VALUES ('F7329', 'UHC Options PPO');
INSERT INTO takes VALUES ('F7329', 'Aetna Managed Choice POS Open Access');
INSERT INTO takes VALUES ('F7329', 'PHCS PPO');
INSERT INTO takes VALUES ('F7329', 'BCBS TX HMO Blue Texas');
INSERT INTO takes VALUES ('F7329', 'Imagine Health SmartCare');
INSERT INTO takes VALUES ('F7329', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('F7329', 'Multiplan PPO');
INSERT INTO takes VALUES ('F7329', 'CIGNA Open Access Plus');
INSERT INTO takes VALUES ('F7329', 'CIGNA HMO');
INSERT INTO takes VALUES ('F7329', 'Humana National POS');
INSERT INTO takes VALUES ('F7329', 'Aetna HMO');
INSERT INTO takes VALUES ('F7329', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('F7329', 'BCBS TX Blue Advantage HMO');
INSERT INTO takes VALUES ('F7329', 'UHC Navigate HMO');
INSERT INTO takes VALUES ('F7329', 'Aetna Signature Administrators PPO');
INSERT INTO takes VALUES ('F7329', 'UHC Choice Plus POS');
INSERT INTO takes VALUES ('F7329', 'CIGNA PPO');
INSERT INTO takes VALUES ('F7329', 'UHC Navigate POS');
INSERT INTO takes VALUES ('F7329', 'Humana Preferred PPO');
INSERT INTO takes VALUES ('F7329', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('F7329', 'BCBS TX BlueChoice');
INSERT INTO takes VALUES ('F7329', 'First Health PPO');
INSERT INTO takes VALUES ('F7329', 'Humana Choice POS');
INSERT INTO takes VALUES ('F7329', 'Aexcel PPO');
INSERT INTO takes VALUES ('F7329', 'Blue Essentials HMO');
INSERT INTO takes VALUES ('F7329', 'MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO takes VALUES ('F7329', 'UHC NAVIGATE PLUS POS');
INSERT INTO takes VALUES ('L3879', 'BCBS Texas BlueChoice');
INSERT INTO takes VALUES ('L3879', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('L3879', 'Aetna HMO');
INSERT INTO takes VALUES ('L3879', 'CIGNA HMO');
INSERT INTO takes VALUES ('L3879', 'CIGNA Open Access');
INSERT INTO takes VALUES ('L3879', 'CIGNA PPO');
INSERT INTO takes VALUES ('L3879', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('L3879', 'Multiplan PHCS PPO');
INSERT INTO takes VALUES ('L3879', 'Multiplan PPO');
INSERT INTO takes VALUES ('L3879', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('L3879', 'Great West PPO');
INSERT INTO takes VALUES ('L3879', 'United Healthcare - Direct Choice Plus POS');
INSERT INTO takes VALUES ('L3879', 'United Healthcare - Direct Options PPO');
INSERT INTO takes VALUES ('Q3615', 'CIGNA Open Access Plus');
INSERT INTO takes VALUES ('Q3615', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('Q3615', 'CIGNA PPO');
INSERT INTO takes VALUES ('Q3615', 'CIGNA HMO');
INSERT INTO takes VALUES ('Q3615', 'Aetna HMO');
INSERT INTO takes VALUES ('Q3615', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('Q3615', 'UHC Choice Plus POS');
INSERT INTO takes VALUES ('Q3615', 'UHC Options PPO');
INSERT INTO takes VALUES ('Q3615', 'BCBS TX BlueChoice');
INSERT INTO takes VALUES ('Q3615', 'Scott and White PPO');
INSERT INTO takes VALUES ('Q3615', 'Humana National POS');
INSERT INTO takes VALUES ('Q3615', 'UHC Navigate HMO');
INSERT INTO takes VALUES ('Q3615', 'CIGNA LocalPlus');
INSERT INTO takes VALUES ('Q3615', 'Humana Choice POS');
INSERT INTO takes VALUES ('Q3615', 'UHC Navigate POS');
INSERT INTO takes VALUES ('Q3615', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('Q3615', 'Aetna Managed Choice POS Open Access');
INSERT INTO takes VALUES ('Q3615', 'BCBS TX HMO Blue Texas');
INSERT INTO takes VALUES ('Q3615', 'Ambetter from Superior HealthPlan MRF');
INSERT INTO takes VALUES ('Q3615', 'Humana Preferred PPO');
INSERT INTO takes VALUES ('Q3615', 'Aexcel PPO');
INSERT INTO takes VALUES ('Q3615', 'MEDICA CHOICE WITH UNITEDHEALTHC');
INSERT INTO takes VALUES ('Q3615', 'UHC NAVIGATE PLUS POS');
INSERT INTO takes VALUES ('F3376', 'Aetna Choice POS II');
INSERT INTO takes VALUES ('F3376', 'Aetna HMO');
INSERT INTO takes VALUES ('F3376', 'BCBS Blue Card PPO');
INSERT INTO takes VALUES ('F3376', 'BCBS California CaliforniaCare HMO');
INSERT INTO takes VALUES ('F3376', 'BCBS California PowerSelect HMO');
INSERT INTO takes VALUES ('F3376', 'BCBS California PPO');
INSERT INTO takes VALUES ('F3376', 'BCBS Texas BlueChoice');
INSERT INTO takes VALUES ('F3376', 'Blue Shield CA Local Access Plus HMO');
INSERT INTO takes VALUES ('F3376', 'Blue Shield California HMO');
INSERT INTO takes VALUES ('F3376', 'Blue Shield California PPO');
INSERT INTO takes VALUES ('F3376', 'CIGNA HMO');
INSERT INTO takes VALUES ('F3376', 'CIGNA Open Access');
INSERT INTO takes VALUES ('F3376', 'CIGNA PPO');
INSERT INTO takes VALUES ('F3376', 'First Health PPO');
INSERT INTO takes VALUES ('F3376', 'Great West PPO');
INSERT INTO takes VALUES ('F3376', 'Health Net California Large Group PPO');
INSERT INTO takes VALUES ('F3376', 'Humana ChoiceCare Network PPO');
INSERT INTO takes VALUES ('F3376', 'Multiplan PHCS PPO');
INSERT INTO takes VALUES ('F3376', 'Multiplan PHCS PPO - Kaiser');
INSERT INTO takes VALUES ('F3376', 'Multiplan PPO');
INSERT INTO takes VALUES ('F3376', 'Pacificare HMO');
INSERT INTO takes VALUES ('F3376', 'United Healthcare - Direct Choice Plus POS');
INSERT INTO takes VALUES ('F3376', 'United Healthcare - Direct Options PPO');



INSERT INTO certified_as VALUES ('Q5315', 'Internal Medicine');
INSERT INTO certified_as VALUES ('Q1081', 'Family Medicine');
INSERT INTO certified_as VALUES ('F0999', 'Endocrinology');
INSERT INTO certified_as VALUES ('R7018', 'Internal Medicine');
INSERT INTO certified_as VALUES ('M4788', 'Endocrinology');
INSERT INTO certified_as VALUES ('L0853', 'Internal Medicine');
INSERT INTO certified_as VALUES ('AP124414', 'Advanced Practice Nurse');
INSERT INTO certified_as VALUES ('H0732', 'Internal Medicine');
INSERT INTO certified_as VALUES ('K8967', 'Endocrinology');
INSERT INTO certified_as VALUES ('N7080', 'Endocrinology');
INSERT INTO certified_as VALUES ('J0224', 'Internal Medicine');
INSERT INTO certified_as VALUES ('G4949', 'Internal Medicine');
INSERT INTO certified_as VALUES ('F1999', 'Endocrinology');
INSERT INTO certified_as VALUES ('M2140', 'Endocrinology');
INSERT INTO certified_as VALUES ('F3376', 'General Practice');
INSERT INTO certified_as VALUES ('Q3615', 'Internal Medicine');
INSERT INTO certified_as VALUES ('L3879', 'Internal Medicine');
INSERT INTO certified_as VALUES ('70441', 'Licensed Professional Counselor');
INSERT INTO certified_as VALUES ('G8361', 'Plastic Surgery');
INSERT INTO certified_as VALUES ('R0531', 'Obstretrics and Gynecology');
INSERT INTO certified_as VALUES ('S2055', 'Obstretrics and Gynecology');
INSERT INTO certified_as VALUES ('L8664', 'Family Medicine');
INSERT INTO certified_as VALUES ('F7329', 'Family Medicine');
INSERT INTO certified_as VALUES ('K9285', 'Family Medicine');
INSERT INTO certified_as VALUES ('L1500', 'Family Medicine');


INSERT INTO works_at VALUES ('Q5315', 'UT Southwestern Medical Center');
INSERT INTO works_at VALUES ('Q1081', 'Southwest Family Medicine');
INSERT INTO works_at VALUES ('F0999', 'Dr. David Feinstein');
INSERT INTO works_at VALUES ('R7018', 'Methodist Health Center - Oak Lawn');
INSERT INTO works_at VALUES ('K9285', 'Dr. Ronald Giometti');
INSERT INTO works_at VALUES ('M4788', 'Southern Endocrinology and Diabetes Associates');
INSERT INTO works_at VALUES ('L0853', 'Uptown Physicians Group');
INSERT INTO works_at VALUES ('AP124414', 'Uptown Physicians Group');
INSERT INTO works_at VALUES ('H0732', 'Dr. Steven Pounders');
INSERT INTO works_at VALUES ('K8967', 'Endocrine and Thyroid Center');
INSERT INTO works_at VALUES ('N7080', 'Diabetes and Endocrinology Clinical Consultants of Texas');
INSERT INTO works_at VALUES ('J0224', 'Dr. Stockton Roberts');
INSERT INTO works_at VALUES ('G4949', 'Methodist Health Center - Oak Lawn');
INSERT INTO works_at VALUES ('F1999', 'Southern Endocrinology and Diabetes Associates');
INSERT INTO works_at VALUES ('M2140', 'Thyroid Endocrinology and Diabetes');
INSERT INTO works_at VALUES ('F3376', 'Dr. Terry Watson');
INSERT INTO works_at VALUES ('Q3615', 'Endocrine Associates of Dallas');
INSERT INTO works_at VALUES ('L3879', 'HealthCore Physicians Group');
INSERT INTO works_at VALUES ('F7329', 'Dallas Family Medicine');
INSERT INTO works_at VALUES ('L1500', 'Dr. Aimee Wright');
INSERT INTO works_at VALUES ('70441', 'Dr. Renee Baker');
INSERT INTO works_at VALUES ('G8361', 'American Institute for Plastic Survery');
INSERT INTO works_at VALUES ('R0531', 'Baylor Scott & White Women''s Health Group');
INSERT INTO works_at VALUES ('S2055', 'Transcend Medical Group');
INSERT INTO works_at VALUES ('L8664', 'Baylor Scott & White Family Medical Center - North Garland');


INSERT INTO posted_to VALUES ('N7080', 10000);
INSERT INTO posted_to VALUES ('L8664', 10002);
INSERT INTO posted_to VALUES ('S2055', 10001);
