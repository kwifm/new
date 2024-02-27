/****** OBJECT:  VIEW [DONSMITH].[NEI_DIR]  RESOLVING case sensitivity issue  SCRIPT DATE: 2/23/2024 7:16:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [DONSMITH].[NEI_DIR]
AS SELECT UNIQUEIDENTIFIER    NED_NIH_ID
     , PERSONALTITLE       NED_PERSONAL_TITLE
     , GIVENNAME           NED_FIRST_NAME
     , MIDDLENAME          NED_MIDDLE_NAME
     , SN                  NED_LAST_NAME
     , GENERATIONQUALIF    NED_GENERATION
     , NIHSUFFIXQUALIFIER  NED_PERSONAL_SUFFIX
     , INITIALS            NED_INITIALS
     , ORGANIZATIONALSTAT  NED_PERSON_CLASSIFICATION
     , NIHSAC              NED_SAC
     , NIHOUNAME           NED_ORGANIZATIONAL_UNIT_NAME
     , TITLE               NED_ORGANIZATIONAL_TITLE
     , TELEPHONENUMBER     NED_OFFICE_TELEPHONE_NUMBER
     , FACSIMILETELEPHONE  NED_OFFICE_FAX_NUMBER
     , PAGERTELEPHONENUM   NED_PAGER_TELEPHONE_NUMBER
     , MOBILETELEPHONENUM  NED_MOBILE_TELEPHONE_NUMBER
     , ROOMNUMBER          NED_ROOM_NUMBER
     , MAIL                NED_EMAIL
     , NIHUNIQUEMAIL       NED_EMAIL_ALIAS
     , L                   NED_OFFICE_CITY
     , ST                  NED_OFFICE_STATE
     , C                   NED_OFFICE_COUNTRY
     , NIHPHYSICALADDRESS  NED_OFFICE_ADDRESS
     , NIHMAILSTOP         NED_MAILSTOP_CODE
     , NIHDELIVERYADDRESS  NED_PVT_CARRIER_DELVRY_ADDRESS
     , POSTALCODE          NED_ZIPCODE
     , POSTALADDRESS       NED_POSTAL_ADDRESS
     , NED_EMAIL_ALIAS2    NED_EMAIL_ALIAS2
     , BUILDINGNAME        NED_BUILDING_ABBREVIATION
     , NIHBUILDINGFULLNAME NED_BUILDING_NAME
     , NIHMODIFYTIMESTAMP  NED_LAST_MODIFIED_TIMESTAMP
     , NEI_COMMON_NAME_FIRST
     , NEI_COMMON_NAME_LAST
     , NEI_FULL_NAME
     , NEI_AD_USERID
     , NEI_OFFICE_PHONE_NUMBER
     , NEI_OFFICE_FAX_NUMBER
     , NEI_PAGER_PHONE_NUMBER
     , NEI_MOBILE_PHONE_NUMBER
     , NEI_OFFICE_PHONE_EXTENSION
     , NEI_LAST_UPDATED_DATE
     , NED_PREFERRED_NAME
     , NED_BUILDING_LOCATION
     , NIHORGPATH          NED_ORG_UNIT_ABBREVIATION
     , DESCRIPTION         NED_COMMENTS
     , NIHCREATORSNAME     NED_CREATORS_NIH_ID
     , NIHCREATETIMESTAMP  NED_CREATE_TIMESTAMP
     , NIHMODIFIERSNAME    NED_MODIFIERS_NIH_ID
     , NIHDIRENTRYNOPRINT  NED_TELEPHONE_DIRECTORY_STATUS
     , NIHIDBADGEREQDATE   NED_IDBADGE_REQUEST_DATE
     , NIHIDBADGEISSUEREA  NED_IDBADGE_ISSUE_REASON
     , NIHIDBADGEEXPDATE   NED_IDBADGE_EXPIRATION_DATE
     , NIHTTY              NED_TTY
     , NIHLIBRARYAUTH      NED_LIBRARY_AUTH
  FROM PANW.NEI_DIR_PRO;
GO 

------------------------------------------------------------------------
------------------------------------------------------------------------
/****** Object:  View [HR_DB].[ALL_PERSONNEL_VW]    Script Date: 2/23/2024 1:05:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 
ALTER   VIEW [HR_DB].[ALL_PERSONNEL_VW]
 
AS
 
SELECT pc.IC,pc.ID,pc.LAST_NAME,pc.FIRST_NAME,pc.COMPANY_NAME,pc.SAC_CODE,pc.DEPARTMENT,pc.CURRENT_SLOT_TYPE,pc.BUILDING,pc.ROOM, pc.AD_USER_ID, pc.FAX, pc.MAIL_STOP,
CASE WHEN ord.POSITION_TITLE IS NOT NULL AND ord.POSITION_TITLE != pc.POSITION_TITLE THEN ord.POSITION_TITLE ELSE pc.POSITION_TITLE END AS POSITION_TITLE,
CASE WHEN ord.POSITION_TITLE IS NULL OR ord.POSITION_TITLE = pc.POSITION_TITLE THEN NULL ELSE pc.POSITION_TITLE END AS ORIGINAL_POSITION_TITLE,
CASE WHEN ord.SUPERVISOR IS NOT NULL AND ord.SUPERVISOR != pc.SUPERVISOR THEN ord.SUPERVISOR ELSE pc.SUPERVISOR END AS SUPERVISOR,
CASE WHEN ord.SUPERVISOR IS NULL OR ord.SUPERVISOR = pc.SUPERVISOR THEN NULL ELSE pc.SUPERVISOR END AS ORIGINAL_SUPERVISOR,
CASE WHEN ord.SUPERVISOR IS NOT NULL AND ord.SUPERVISOR != pc.SUPERVISOR THEN sup.ID ELSE pc.SUPERVISOR_ID END AS SUPERVISOR_ID,
pc.LOCATION, pc.NIH_START_DATE,pc.IC_START_DATE,pc.LAST_QSI_DATE,pc.LAST_WIGI_DATE,pc.LAST_PROMOTION_DATE,pc.PAY_PLAN,pc.SERIES,
CAST(pc.GRADE AS varchar) AS GRADE,CAST(pc.STEP AS varchar) AS STEP,pc.PHONE,pc.EMAIL,pc.CURRENT_NTE_DATE,ISNULL(pc.CAN,ord.CAN) AS CAN,pc.SALARY AS SALARY,
pc.BENEFIT AS BENEFIT, pc.PART_TIME,ord.ORIGINAL_SLOT_TYPE,ord.VICE_STATUS,ord.VICE_NAME,ord.VICE_DEPARTURE_DATE,ord.QUAD_REVIEW_DATE,
ord.QUAD_PAY_INCREASE_DATE,ord.NEXT_PERSONNEL_ACTION,ord.FELLOWSHIP_YEAR,ord.FULL_PERFORMANCE_LEVEL,ord.PART_TIME_HOURS,
ord.CONTRACTOR_COSTS,ord.DEPARTURE_DATE,ord.COMMENTS,ord.LEAD_TIME,ord.STATUS,ord.FELLOWSHIP_EXPERIENCE,ord.HIDDEN_IN_ORGCHART,sco.IS_HEAD AS PRIMARY_HEAD,sco.SAC_HIDDEN_IN_REPORT,'nVision' AS RECORD_TYPE, CASE WHEN ord.ID IS NOT NULL THEN 1 ELSE 0 END AS HAS_ADDITIONAL_SACS,s.SLOT_NUMBER, pc.NIHSUBORGSTATUS,
s.NOTES AS SLOT_NOTES, pc.WIGI_DUE_DT
FROM HR_DB.PERSONNEL_CURRENT pc
LEFT JOIN HR_DB.OVERRIDE_RECORD ord ON pc.ID = ord.ID
LEFT JOIN HR_DB.SAC_CODE_OVERRIDES sco ON sco.ID = ord.ID AND sco.SAC_CODE = pc.SAC_CODE
LEFT JOIN HR_DB.SLOT s ON (s.ASSIGNED_TO = pc.ID OR s.VICE = pc.ID)
LEFT JOIN HR_DB.PERSONNEL_CURRENT sup ON CONCAT(sup.FIRST_NAME, ' ', sup.LAST_NAME) = ord.SUPERVISOR AND LEN(LTRIM(RTRIM(ord.SUPERVISOR))) > 0 AND sup.IC = pc.IC
UNION ALL
SELECT nr.IC,nr.ID,nr.LAST_NAME,nr.FIRST_NAME,nr.COMPANY_NAME,sco.SAC_CODE, dbo.InitCap(hod.ORG_NAME) AS DEPARTMENT,nr.CURRENT_SLOT_TYPE,nr.BUILDING,NULL AS AD_USER_ID, NULL AS FAX, NULL AS MAIL_STOP,nr.ROOM,nr.POSITION_TITLE,NULL AS ORIGINAL_POSITION_TITLE, nr.SUPERVISOR, NULL AS ORIGINAL_SUPERVISOR,
sup.ID AS SUPERVISOR_ID, NULL AS LOCATION, nr.NIH_START_DATE,nr.IC_START_DATE,nr.LAST_QSI_DATE,nr.LAST_WIGI_DATE,nr.LAST_PROMOTION_DATE,nr.PAY_PLAN,nr.SERIES,nr.GRADE,nr.STEP,nr.PHONE,nr.EMAIL,nr.CURRENT_NTE_DATE,nr.CAN,CAST(nr.SALARY as numeric) as SALARY,CAST(nr.BENEFIT AS float) AS BENEFIT,
nr.PART_TIME,nr.ORIGINAL_SLOT_TYPE,nr.VICE_STATUS,nr.VICE_NAME,nr.VICE_DEPARTURE_DATE,nr.QUAD_REVIEW_DATE,nr.QUAD_PAY_INCREASE_DATE,nr.NEXT_PERSONNEL_ACTION,nr.FELLOWSHIP_YEAR,nr.FULL_PERFORMANCE_LEVEL,nr.PART_TIME_HOURS,nr.CONTRACTOR_COSTS,
NULL AS DEPARTURE_DATE,nr.COMMENTS,nr.LEAD_TIME,nr.STATUS,nr.FELLOWSHIP_EXPERIENCE,nr.HIDDEN_IN_ORGCHART,sco.IS_HEAD AS PRIMARY_HEAD,sco.SAC_HIDDEN_IN_REPORT,nr.RECORD_TYPE, 1 AS HAS_ADDITIONAL_SACS, s.SLOT_NUMBER, NULL AS NIHSUBORGSTATUS,
s.NOTES AS SLOT_NOTES, NULL AS WIGI_DUE_DT
FROM HR_DB.NEW_RECORD nr
LEFT JOIN HR_DB.SAC_CODE_OVERRIDES sco ON sco.ID = nr.ID AND sco.IS_PRIMARY = 1
LEFT JOIN HR_DB.HR_ORG_DIM hod ON hod.ORG_CD = sco.SAC_CODE AND hod.LATEST_REC_FLG = 'Y' AND hod.ORG_INITS IS NOT NULL
LEFT JOIN HR_DB.SLOT s ON (s.ASSIGNED_TO = nr.ID OR s.VICE = nr.ID)
LEFT JOIN HR_DB.PERSONNEL_CURRENT sup ON CONCAT(sup.FIRST_NAME, ' ', sup.LAST_NAME) = nr.SUPERVISOR AND LEN(LTRIM(RTRIM(nr.SUPERVISOR))) > 0 AND sup.IC = nr.IC
GO

--------------------------------------------------------------
--------------------------------------------------------------
/****** Object:  View [DONSMITH].[NEI_DIR_EVERYONE]    Script Date: 2/23/2024 1:07:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [DONSMITH].[NEI_DIR_EVERYONE]
AS SELECT
    b.NED_NIH_ID,
    b.NED_FIRST_NAME,
    b.NED_LAST_NAME
FROM
    DONSMITH.NEI_DIR b
UNION
SELECT DISTINCT
    (a.NED_NIH_ID),
    a.NED_FIRST_NAME,
    a.NED_LAST_NAME
FROM
    DONSMITH.NEI_DIR_TRANS a
WHERE
    a.NED_NIH_ID is not null and NOT EXISTS (
        SELECT 1 
        FROM DONSMITH.NEI_DIR b 
        where b.NED_NIH_ID = a.NED_NIH_ID
    );
GO

--------------------------------------------------------------
--------------------------------------------------------------

/****** Object:  View [NMCA].[NEI_DIR_NMCA]    Script Date: 2/23/2024 1:15:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [NMCA].[NEI_DIR_NMCA] (
   UNIQUEIDENTIFIER, 
   GIVENNAME, 
   MIDDLENAME, 
   SN, 
   ORGANIZATIONALSTAT, 
   NIHSAC, 
   BRANCH, 
   LAB, 
   NEI_AD_USERID, 
   MAIL, 
   NEI_COMMON_NAME_LAST)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 8.1.0.*/
   SELECT 
      NEI_DIR_PLACEHOLDER.UNIQUEIDENTIFIER, 
      NEI_DIR_PLACEHOLDER.GIVENNAME, 
      NEI_DIR_PLACEHOLDER.MIDDLENAME, 
      NEI_DIR_PLACEHOLDER.SN, 
      NEI_DIR_PLACEHOLDER.ORGANIZATIONALSTAT, 
      NEI_DIR_PLACEHOLDER.NIHSAC, 
      NEI_DIR_PLACEHOLDER.BRANCH, 
      NEI_DIR_PLACEHOLDER.LAB, 
      NEI_DIR_PLACEHOLDER.NEI_AD_USERID, 
      NEI_DIR_PLACEHOLDER.MAIL, 
      NEI_DIR_PLACEHOLDER.NEI_COMMON_NAME_LAST
   FROM NMCA.NEI_DIR_PLACEHOLDER
    UNION
   SELECT 
      DS.NED_NIH_ID AS UNIQUEIDENTIFIER, 
      DS.NED_FIRST_NAME AS GIVENNAME, 
      NULL AS MIDDLENAME, 
      DS.NED_LAST_NAME AS SN, 
      '-' AS ORGANIZATIONALSTAT, 
      '-' AS NIHSAC, 
      '-' AS BRANCH, 
      '-' AS LAB, 
      NULL AS NEI_AD_USERID, 
      PW.MAIL AS MAIL, 
      (ISNULL(DS.NED_LAST_NAME, '') + ', ' + ISNULL(DS.NED_FIRST_NAME, '')) AS NEI_COMMON_NAME_LAST
   FROM 
      DONSMITH.NEI_DIR_EVERYONE  AS DS 
         LEFT JOIN PANW.NEI_DIR_PRO  AS PW 
         ON PW.UNIQUEIDENTIFIER = DS.NED_NIH_ID;
-- */

GO

---------------------------------------------------------
---------------------------------------------------------
/****** Object:  View [PUBDATA].[MV_HS_UNIGENE_CHROM]    Script Date: 2/23/2024 2:11:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER VIEW [PUBDATA].[MV_HS_UNIGENE_CHROM] ("UNIGENE", "CHR", "TSTART", "TEND")
 
  AS Select a.UNIGENE, Substring(b.CHROM, 4,17) as Chr,
	   b.TSTART, b.TEND
From PUBDATA.V_HSUNIGENE_MAXSCORE a
Join PUBDATA.HS_UNIGENE_BLAT b
On (a.UNIGENE = b.UNIGENE And a.MAXSCORE = b.SCORE);
GO



