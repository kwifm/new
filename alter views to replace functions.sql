/****** Object:  View [IDP].[IDP_DISCREPANCY_VW]  Replacing [ssma_oracle].[initcap_varchar] with [dbo].[InitCap]  Script Date: 2/23/2024 12:13:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [IDP].[IDP_DISCREPANCY_VW] (
   PLAN_ID, 
   TRAINEE_NED_ID, 
   TRAINEE_NAME, 
   EMAIL_ADDRESS, 
   PLAN_TRAINING_ORG, 
   NED_ORGPATH, 
   IDP_TYPE, 
   AWD_FRM_DATE, 
   AWD_TO_DATE, 
   TRAINING_DIRECTOR_NED_ID, 
   CURR_IDP_STATUS, 
   CLASSIFICATION_CHANGED, 
   INACTIVE_PM, 
   INACTIVE_COPI, 
   INACTIVE_AM, 
   INACTIVE_LBO, 
   DIFF_MEETING_DATE, 
   DECLINED_BY_PM, 
   MAX_WORKFLOW_LIMIT_REACHED, 
   REN_AWD_ACT, 
   HI_DEG_FLAG, 
   CURR_YR_TRAIN_FLAG, 
   ON_HOLD_CO_PI, 
   ON_HOLD)
AS 
   SELECT 
      P.ID, 
      P.TRAINEE_NED_ID, 
      dbo.InitCap(ISNULL(
         CASE 
            WHEN TS.PREFERRED_LAST_NAME IS NOT NULL THEN TS.PREFERRED_LAST_NAME
            ELSE TS.LAST_NAME
         END, '') + ', ' + ISNULL(
         CASE 
            WHEN TS.PREFERRED_FIRST_NAME IS NOT NULL THEN TS.PREFERRED_FIRST_NAME
            ELSE TS.FIRST_NAME
         END, '')), 
      TS.EMAIL_ADDRESS, 
      P.NCI_DOC_ORG_PATH, 
      TS.NIHORGPATH, 
      P.IDP_TYPE_ID, 
      TS.AWD_PRD_FROM_DT, 
      TS.AWD_PRD_TO_DT, 
      CASE 
         WHEN P.ID IS NOT NULL THEN 
            (
               SELECT DOCS_VW.TRAINING_DIRECTOR_NED_ID
               FROM IDP.DOCS_VW
               WHERE DOCS_VW.NIHSAC = P.NED_NIHSAC
            )
         ELSE NULL
      END AS TRAINING_DIRECTOR_NED_ID, 
      CASE 
         WHEN P.ID IN 
            (
               SELECT PLAN_STATUS_T.PLAN_ID
               FROM IDP.PLAN_STATUS_T
               WHERE PLAN_STATUS_T.ROLE_ID = 100
            ) THEN 
            (
               SELECT L.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L
               WHERE L.ID = 
                  (
                     SELECT PLAN_STATUS_T$7.STATUS_ID
                     FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$7
                     WHERE PLAN_STATUS_T$7.ROLE_ID = 100 AND PLAN_STATUS_T$7.PLAN_ID = P.ID
                  )
            )
         ELSE 'NOTSTARTED'
      END AS CURR_IDP_STATUS, 
      CASE 
         WHEN 
            P.CURRENT_AWARD_DATE_TO IS NOT NULL AND 
            P.CURRENT_AWARD_DATE_TO >= sysdatetime() AND 
            TS.AWD_PRD_TO_DT >= sysdatetime() AND 
            NED.ORGANIZATIONALSTAT = 'EMPLOYEE' AND 
            /* IDP-1045 and IDP-1046: Status not Cancelled*/EXISTS 
            (
               SELECT STATUSES_T.ID
               FROM IDP.STATUSES_T
               WHERE STATUSES_T.PLAN_ID = P.ID AND STATUSES_T.STATUS_ID != 38
            ) THEN 'Y'
         ELSE 'N'
      END AS CLASSIFICATION_CHANGED, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$2.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$2
               WHERE 
                  STATUSES_T$2.PLAN_ID = P.ID AND 
                  STATUSES_T$2.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$2.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            
            (
               SELECT NED_PERSON_T$3.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$3
               WHERE NED_PERSON_T$3.CURRENT_FLAG = 'Y' AND NED_PERSON_T$3.UNIQUEIDENTIFIER = 
                  (
                     SELECT MENTORS_T$3.MENTOR_NED_ID
                     FROM IDP.MENTORS_T  AS MENTORS_T$3
                     WHERE MENTORS_T$3.PLAN_ID = P.ID AND MENTORS_T$3.PRIMARY_MENTOR_FLAG = 'Y'
                  )
            ) IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_PM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$3.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$3
               WHERE 
                  STATUSES_T$3.PLAN_ID = P.ID AND 
                  STATUSES_T$3.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$3.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            EXISTS 
            (
               SELECT NED_PERSON_T.INACTIVE_DATE
               FROM IDP.NED_PERSON_T
               WHERE 
                  NED_PERSON_T.CURRENT_FLAG = 'Y' AND 
                  NED_PERSON_T.INACTIVE_DATE IS NOT NULL AND 
                  NED_PERSON_T.UNIQUEIDENTIFIER IN 
                  (
                     SELECT MENTORS_T.MENTOR_NED_ID
                     FROM IDP.MENTORS_T
                     WHERE 
                        MENTORS_T.PLAN_ID = P.ID AND 
                        MENTORS_T.PRIMARY_MENTOR_FLAG = 'N' AND 
                        MENTORS_T.ISCO_PI = 'Y'
                  )
            ) THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_COPI, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$4.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$4
               WHERE 
                  STATUSES_T$4.PLAN_ID = P.ID AND 
                  STATUSES_T$4.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$4.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            EXISTS 
            (
               SELECT NED_PERSON_T$2.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$2
               WHERE 
                  NED_PERSON_T$2.CURRENT_FLAG = 'Y' AND 
                  NED_PERSON_T$2.INACTIVE_DATE IS NOT NULL AND 
                  NED_PERSON_T$2.UNIQUEIDENTIFIER IN 
                  (
                     SELECT MENTORS_T$2.MENTOR_NED_ID
                     FROM IDP.MENTORS_T  AS MENTORS_T$2
                     WHERE 
                        MENTORS_T$2.PLAN_ID = P.ID AND 
                        MENTORS_T$2.PRIMARY_MENTOR_FLAG = 'N' AND 
                        MENTORS_T$2.ISCO_PI = 'N'
                  )
            ) THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_AM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$5.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$5
               WHERE 
                  STATUSES_T$5.PLAN_ID = P.ID AND 
                  STATUSES_T$5.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$5.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            
            (
               SELECT NED_PERSON_T$4.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$4
               WHERE NED_PERSON_T$4.CURRENT_FLAG = 'Y' AND NED_PERSON_T$4.UNIQUEIDENTIFIER = P.LBO_CHF_DIR_NED_ID
            ) IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_LBO, 
      CASE 
         WHEN (EXISTS 
            (
               SELECT PLAN_STATUS_T$6.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$6
               WHERE 
                  PLAN_STATUS_T$6.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$6.STATUS_ID = 246 AND 
                  PLAN_STATUS_T$6.ROLE_ID = 100
            ) OR 
            (
               SELECT SSMAROWNUM$4.ACTIVITY
               FROM 
                  (
                     SELECT ACTIVITY, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$4.ACTIVITY, fci$4.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T$3.PLAN_ID, PLAN_WORKFLOW_T$3.ACTIVITY
                                 FROM IDP.PLAN_WORKFLOW_T  AS PLAN_WORKFLOW_T$3
                                 WHERE PLAN_WORKFLOW_T$3.ACTIVITY IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T$3.ID DESC
                              )  AS fci$4
                           WHERE fci$4.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$4
                  )  AS SSMAROWNUM$4
               WHERE SSMAROWNUM$4.PLAN_ID = P.ID AND SSMAROWNUM$4.ROWNUM = 1
            ) = 278) AND 
            (
               SELECT SSMAROWNUM.MEETING_VERIFIC_DATE
               FROM 
                  (
                     SELECT MEETING_VERIFIC_DATE, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci.MEETING_VERIFIC_DATE, fci.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PWT.PLAN_ID, PWT.MEETING_VERIFIC_DATE
                                 FROM IDP.PLAN_WORKFLOW_T  AS PWT
                                 WHERE PWT.ROLE_ID = 100 AND PWT.MEETING_VERIFIC_DATE IS NOT NULL
                                 ORDER BY PWT.ID DESC
                              )  AS fci
                           WHERE fci.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO
                  )  AS SSMAROWNUM
               WHERE SSMAROWNUM.PLAN_ID = P.ID AND SSMAROWNUM.ROWNUM < 2
            ) != 
            (
               SELECT SSMAROWNUM$2.MEETING_VERIFIC_DATE
               FROM 
                  (
                     SELECT MEETING_VERIFIC_DATE, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$2.MEETING_VERIFIC_DATE, fci$2.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T.PLAN_ID, PLAN_WORKFLOW_T.MEETING_VERIFIC_DATE
                                 FROM IDP.PLAN_WORKFLOW_T
                                 WHERE PLAN_WORKFLOW_T.ROLE_ID = 103 AND PLAN_WORKFLOW_T.MEETING_VERIFIC_DATE IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T.ID DESC
                              )  AS fci$2
                           WHERE fci$2.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$2
                  )  AS SSMAROWNUM$2
               WHERE SSMAROWNUM$2.PLAN_ID = P.ID AND SSMAROWNUM$2.ROWNUM < 2
            ) THEN 'Y'
         ELSE 'N'
      END AS DIFF_MEETING_DATE, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$2.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$2
               WHERE 
                  PLAN_STATUS_T$2.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$2.STATUS_ID = 233 AND 
                  PLAN_STATUS_T$2.ROLE_ID = 100
            ) AND 
            (
               SELECT SSMAROWNUM$3.ACTIVITY
               FROM 
                  (
                     SELECT ACTIVITY, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$3.ACTIVITY, fci$3.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T$2.PLAN_ID, PLAN_WORKFLOW_T$2.ACTIVITY
                                 FROM IDP.PLAN_WORKFLOW_T  AS PLAN_WORKFLOW_T$2
                                 WHERE PLAN_WORKFLOW_T$2.ACTIVITY IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T$2.ID DESC
                              )  AS fci$3
                           WHERE fci$3.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$3
                  )  AS SSMAROWNUM$3
               WHERE SSMAROWNUM$3.PLAN_ID = P.ID AND SSMAROWNUM$3.ROWNUM = 1
            ) = 265 THEN 'Y'
         ELSE 'N'
      END AS DECLINED_BY_PM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT PLAN_STATUS_T$3.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$3
               WHERE 
                  PLAN_STATUS_T$3.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$3.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$3.STATUS_ID IN ( 233, 36, 234 )
            ) AND 
            EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T.ID
               FROM IDP.PLAN_SENT_COUNTER_T
               WHERE 
                  PLAN_SENT_COUNTER_T.PLAN_ID = P.ID AND 
                  PLAN_SENT_COUNTER_T.TO_MENTOR = 4 AND 
                  PLAN_SENT_COUNTER_T.TO_TRAINEE = 4
            ) AND 
            EXISTS 
            (
               SELECT PAGE_STATUS_T.ID
               FROM IDP.PAGE_STATUS_T
               WHERE 
                  PAGE_STATUS_T.PLAN_ID = P.ID AND 
                  (PAGE_STATUS_T.ROLE_ID = 100 OR PAGE_STATUS_T.ROLE_ID = 103) AND 
                  PAGE_STATUS_T.STATUS_ID IN ( 248, 249 )
            ) THEN 'Y'
         ELSE 'N'
      END AS MAX_WORKFLOW_LIMIT_REACHED, 
      CASE 
         WHEN 
            (P.CREATED_DATE NOT BETWEEN TS.AWD_PRD_FROM_DT AND TS.AWD_PRD_TO_DT) AND 
            TS.ACTION_TYPE = 'REN' AND 
            EXISTS 
            (
               SELECT STATUSES_T$6.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$6
               WHERE STATUSES_T$6.PLAN_ID = P.ID AND STATUSES_T$6.STATUS_ID = 34
            ) THEN 'Y'
         ELSE 'N'
      END AS REN_AWD_ACT, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$7.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$7
               WHERE STATUSES_T$7.PLAN_ID = P.ID AND STATUSES_T$7.STATUS_ID = 34
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.HI_EDUCATION_CD IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID != 
            (
               SELECT L$2.ID
               FROM IDP.LOOKUP_T  AS L$2
               WHERE L$2.CODE = CAST(TS.HI_EDUCATION_CD AS varchar(20))
            )) THEN 'Y'
         WHEN EXISTS 
            (
               SELECT STATUSES_T$8.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$8
               WHERE STATUSES_T$8.PLAN_ID = P.ID AND STATUSES_T$8.STATUS_ID = 34
            ) AND (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.HI_EDUCATION_CD IS NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL) THEN 'Y'
         ELSE 'N'
      END AS HI_DEG_FLAG, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$9.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$9
               WHERE STATUSES_T$9.PLAN_ID = P.ID AND STATUSES_T$9.STATUS_ID = 34
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.TRAIN_PROG_START_DT IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID != 
            (
               SELECT L$3.ID
               FROM IDP.LOOKUP_T  AS L$3
               WHERE L$3.DISCRIMINATOR = 'CURRENT_YEAR_OF_TRAINING' AND L$3.DISPLAY_ORDER_NUM = ceiling(ssma_oracle.datediff(sysdatetime(), TS.TRAIN_PROG_START_DT) / 365)
            )) THEN 'Y'
         ELSE 'N'
      END AS CURR_YR_TRAINING_FLAG, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$4.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$4
               WHERE 
                  PLAN_STATUS_T$4.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$4.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$4.STATUS_ID IN (  280 )
            ) AND EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T$2.ID
               FROM IDP.PLAN_SENT_COUNTER_T  AS PLAN_SENT_COUNTER_T$2
               WHERE 
                  PLAN_SENT_COUNTER_T$2.PLAN_ID = P.ID AND 
                  PLAN_SENT_COUNTER_T$2.TO_MENTOR = 4 AND 
                  PLAN_SENT_COUNTER_T$2.TO_TRAINEE = 4
            ) THEN 'Y'
         ELSE 'N'
      END AS ON_HOLD, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$5.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$5
               WHERE 
                  PLAN_STATUS_T$5.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$5.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$5.STATUS_ID IN (  280 )
            ) AND NOT EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T$3.ID
               FROM IDP.PLAN_SENT_COUNTER_T  AS PLAN_SENT_COUNTER_T$3
               WHERE PLAN_SENT_COUNTER_T$3.PLAN_ID = P.ID
            ) THEN 'Y'
         ELSE 'N'
      END AS ON_HOLD_CO_PI
   FROM IDP.PLANS_T  AS P, IDP.NVISION_TRAINEES_T  AS TS, IDP.NED_PERSON_T  AS NED
   WHERE 
      P.TRAINEE_NED_ID = TS.NED_ID AND 
      TS.NED_ID = NED.UNIQUEIDENTIFIER AND 
      P.CURRENT_FLAG = 'Y' AND 
      /*       AND ts.plan_id IS NOT NULL*/NED.CURRENT_FLAG = 'Y' AND 
      TS.NED_ACTIVE_IND = 'Y' AND 
      NED.ORGANIZATIONALSTAT IN ( 'EMPLOYEE', 'FELLOW' )
GO
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
/****** Object:  View [PUBDATA].[V_STSMARKER_UPDATE]  Replacing [ssma_oracle].[substr2_varchar] with SUBSTRING  Script Date: 2/23/2024 12:17:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [PUBDATA].[V_STSMARKER_UPDATE] (
   TRUEMARKER, 
   CHROM, 
   TSTART, 
   TEND)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 8.1.0.*/
   SELECT DISTINCT EXT_STSMARKER_UPDATE.TRUEMARKER, SUBSTRING(EXT_STSMARKER_UPDATE.CHROM, 4, 4) AS CHROM, min(EXT_STSMARKER_UPDATE.TSTART) AS TSTART, max(EXT_STSMARKER_UPDATE.TEND) AS TEND
   FROM PUBDATA.EXT_STSMARKER_UPDATE
   GROUP BY EXT_STSMARKER_UPDATE.TRUEMARKER, EXT_STSMARKER_UPDATE.CHROM
GO

----------------------------------------------------------------------------
----------------------------------------------------------------------------
/****** Object:  View [PUBDATA].[V_GENE2UNIGENE]  Replacing [ssma_oracle].[substr2_varchar] with SUBSTRING  Script Date: 2/23/2024 12:39:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [PUBDATA].[V_GENE2UNIGENE] (GENE_ID, HS_UNIGENE_ID)
AS 
   /*Generated by SQL Server Migration Assistant for Oracle version 8.1.0.*/
   SELECT GENE2UNIGENE.GENE_ID, SUBSTRING(GENE2UNIGENE.UNIGENE_ID, 4, 8) AS HS_UNIGENE_ID
   FROM PUBDATA.GENE2UNIGENE
   WHERE GENE2UNIGENE.UNIGENE_ID LIKE 'Hs%'
GO
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
/****** Object:  View [IDP].[DOCS_EXP_VW]  Replacing [ssma_oracle].[length_varchar] with LEN Script Date: 2/23/2024 12:41:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [IDP].[DOCS_EXP_VW] (
   NIHORGPATH,
   NIHSAC,
   NIHOUACRONYM,
   NIHOUNAME,
   PARTICIPATING_ORG_FLAG,
   TRAINING_DIRECTOR_NED_ID,
   PARTICIPATING_ORG_ACTIVE_FLAG)
AS
   /*Generated by SQL Server Migration Assistant for Oracle version 8.1.0.*/
   /*
   *   SSMA warning messages:
   *   O2SS0273: Oracle SUBSTR function and SQL Server SUBSTRING function may give different results.
   */

   SELECT TOP 9223372036854775807 WITH TIES
      substring(A.NIHORGPATH, 5, LEN(A.NIHORGPATH)) AS NIHORGPATH,
      A.NIHSAC,
      A.NIHOUACRONYM,
      A.NIHOUNAME,
      CASE
         WHEN P.NIHSAC IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS PARTICIPATING_ORG_FLAG,
      P.TRAINING_DIRECTOR_NED_ID,
      P.ACTIVE_FLAG AS PARTICIPATING_ORG_ACTIVE_FLAG
   FROM
      IDP.NED_ORGUNIT_T  AS A
         LEFT OUTER JOIN IDP.PARTICIPATING_ORGS_T  AS P
         ON A.NIHSAC = P.NIHSAC
   WHERE /*  AND (a.nihparentsac IN ('HNC', 'HNC1')         OR (a.nihparentsac IN ('HNC17')            AND p.nihsac IS NOT NULL)      )  -- OWPD*/A.NIHORGACRONYM = 'NEI' AND LEN(A.NIHSAC) > 3
   /*  AND a.nihsac NOT IN ('HNC1-5','HNC17')*/
   ORDER BY 1
GO

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
/****** Object:  View [IDP].[DOCS_VW]  Replacing [ssma_oracle].[length_varchar] with LEN   Script Date: 2/23/2024 12:44:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   VIEW [IDP].[DOCS_VW] (
   NIHORGPATH,
   NIHSAC,
   NIHOUACRONYM,
   NIHOUNAME,
   PARTICIPATING_ORG_FLAG,
   TRAINING_DIRECTOR_NED_ID,
   PARTICIPATING_ORG_ACTIVE_FLAG)
AS
   /*Generated by SQL Server Migration Assistant for Oracle version 8.1.0.*/
   /*
   *   SSMA warning messages:
   *   O2SS0273: Oracle SUBSTR function and SQL Server SUBSTRING function may give different results.
   */
 
   SELECT TOP 9223372036854775807 WITH TIES
      substring(A.NIHORGPATH, 5, LEN(A.NIHORGPATH)) AS NIHORGPATH,
      A.NIHSAC,
      A.NIHOUACRONYM,
      A.NIHOUNAME,
      CASE
         WHEN P.NIHSAC IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS PARTICIPATING_ORG_FLAG,
      P.TRAINING_DIRECTOR_NED_ID,
      P.ACTIVE_FLAG AS PARTICIPATING_ORG_ACTIVE_FLAG
   FROM
      IDP.NED_ORGUNIT_T  AS A
         LEFT OUTER JOIN IDP.PARTICIPATING_ORGS_T  AS P
         ON A.NIHSAC = P.NIHSAC
   WHERE
      A.CURRENT_FLAG = 'Y' AND
      (A.NIHPARENTSAC IN ( 'HNW', 'HNW1' ) OR (A.NIHPARENTSAC IN (  'HNW2'/* TODO: Figure out what this does*/ ) AND P.NIHSAC IS NOT NULL)) AND
      A.NIHORGACRONYM = 'NEI' AND
      LEN(A.NIHSAC) > 3
 
   ORDER BY 1
GO

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
/****** Object:  View [IDP].[IDP_DISCREPANCY_VW]    Script Date: 2/23/2024 3:11:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER VIEW [IDP].[IDP_DISCREPANCY_VW] (
   PLAN_ID, 
   TRAINEE_NED_ID, 
   TRAINEE_NAME, 
   EMAIL_ADDRESS, 
   PLAN_TRAINING_ORG, 
   NED_ORGPATH, 
   IDP_TYPE, 
   AWD_FRM_DATE, 
   AWD_TO_DATE, 
   TRAINING_DIRECTOR_NED_ID, 
   CURR_IDP_STATUS, 
   CLASSIFICATION_CHANGED, 
   INACTIVE_PM, 
   INACTIVE_COPI, 
   INACTIVE_AM, 
   INACTIVE_LBO, 
   DIFF_MEETING_DATE, 
   DECLINED_BY_PM, 
   MAX_WORKFLOW_LIMIT_REACHED, 
   REN_AWD_ACT, 
   HI_DEG_FLAG, 
   CURR_YR_TRAIN_FLAG, 
   ON_HOLD_CO_PI, 
   ON_HOLD)
AS 
   SELECT 
      P.ID, 
      P.TRAINEE_NED_ID, 
      dbo.InitCap(ISNULL(
         CASE 
            WHEN TS.PREFERRED_LAST_NAME IS NOT NULL THEN TS.PREFERRED_LAST_NAME
            ELSE TS.LAST_NAME
         END, '') + ', ' + ISNULL(
         CASE 
            WHEN TS.PREFERRED_FIRST_NAME IS NOT NULL THEN TS.PREFERRED_FIRST_NAME
            ELSE TS.FIRST_NAME
         END, '')), 
      TS.EMAIL_ADDRESS, 
      P.NCI_DOC_ORG_PATH, 
      TS.NIHORGPATH, 
      P.IDP_TYPE_ID, 
      TS.AWD_PRD_FROM_DT, 
      TS.AWD_PRD_TO_DT, 
      CASE 
         WHEN P.ID IS NOT NULL THEN 
            (
               SELECT DOCS_VW.TRAINING_DIRECTOR_NED_ID
               FROM IDP.DOCS_VW
               WHERE DOCS_VW.NIHSAC = P.NED_NIHSAC
            )
         ELSE NULL
      END AS TRAINING_DIRECTOR_NED_ID, 
      CASE 
         WHEN P.ID IN 
            (
               SELECT PLAN_STATUS_T.PLAN_ID
               FROM IDP.PLAN_STATUS_T
               WHERE PLAN_STATUS_T.ROLE_ID = 100
            ) THEN 
            (
               SELECT L.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L
               WHERE L.ID = 
                  (
                     SELECT PLAN_STATUS_T$7.STATUS_ID
                     FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$7
                     WHERE PLAN_STATUS_T$7.ROLE_ID = 100 AND PLAN_STATUS_T$7.PLAN_ID = P.ID
                  )
            )
         ELSE 'NOTSTARTED'
      END AS CURR_IDP_STATUS, 
      CASE 
         WHEN 
            P.CURRENT_AWARD_DATE_TO IS NOT NULL AND 
            P.CURRENT_AWARD_DATE_TO >= sysdatetime() AND 
            TS.AWD_PRD_TO_DT >= sysdatetime() AND 
            NED.ORGANIZATIONALSTAT = 'EMPLOYEE' AND 
            /* IDP-1045 and IDP-1046: Status not Cancelled*/EXISTS 
            (
               SELECT STATUSES_T.ID
               FROM IDP.STATUSES_T
               WHERE STATUSES_T.PLAN_ID = P.ID AND STATUSES_T.STATUS_ID != 38
            ) THEN 'Y'
         ELSE 'N'
      END AS CLASSIFICATION_CHANGED, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$2.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$2
               WHERE 
                  STATUSES_T$2.PLAN_ID = P.ID AND 
                  STATUSES_T$2.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$2.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            
            (
               SELECT NED_PERSON_T$3.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$3
               WHERE NED_PERSON_T$3.CURRENT_FLAG = 'Y' AND NED_PERSON_T$3.UNIQUEIDENTIFIER = 
                  (
                     SELECT MENTORS_T$3.MENTOR_NED_ID
                     FROM IDP.MENTORS_T  AS MENTORS_T$3
                     WHERE MENTORS_T$3.PLAN_ID = P.ID AND MENTORS_T$3.PRIMARY_MENTOR_FLAG = 'Y'
                  )
            ) IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_PM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$3.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$3
               WHERE 
                  STATUSES_T$3.PLAN_ID = P.ID AND 
                  STATUSES_T$3.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$3.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            EXISTS 
            (
               SELECT NED_PERSON_T.INACTIVE_DATE
               FROM IDP.NED_PERSON_T
               WHERE 
                  NED_PERSON_T.CURRENT_FLAG = 'Y' AND 
                  NED_PERSON_T.INACTIVE_DATE IS NOT NULL AND 
                  NED_PERSON_T.UNIQUEIDENTIFIER IN 
                  (
                     SELECT MENTORS_T.MENTOR_NED_ID
                     FROM IDP.MENTORS_T
                     WHERE 
                        MENTORS_T.PLAN_ID = P.ID AND 
                        MENTORS_T.PRIMARY_MENTOR_FLAG = 'N' AND 
                        MENTORS_T.ISCO_PI = 'Y'
                  )
            ) THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_COPI, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$4.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$4
               WHERE 
                  STATUSES_T$4.PLAN_ID = P.ID AND 
                  STATUSES_T$4.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$4.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            EXISTS 
            (
               SELECT NED_PERSON_T$2.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$2
               WHERE 
                  NED_PERSON_T$2.CURRENT_FLAG = 'Y' AND 
                  NED_PERSON_T$2.INACTIVE_DATE IS NOT NULL AND 
                  NED_PERSON_T$2.UNIQUEIDENTIFIER IN 
                  (
                     SELECT MENTORS_T$2.MENTOR_NED_ID
                     FROM IDP.MENTORS_T  AS MENTORS_T$2
                     WHERE 
                        MENTORS_T$2.PLAN_ID = P.ID AND 
                        MENTORS_T$2.PRIMARY_MENTOR_FLAG = 'N' AND 
                        MENTORS_T$2.ISCO_PI = 'N'
                  )
            ) THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_AM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$5.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$5
               WHERE 
                  STATUSES_T$5.PLAN_ID = P.ID AND 
                  STATUSES_T$5.STATUS_ID != 35 AND 
                  /* IDP-1045 and IDP-1046: Status not Cancelled*/STATUSES_T$5.STATUS_ID != 38
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            
            (
               SELECT NED_PERSON_T$4.INACTIVE_DATE
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$4
               WHERE NED_PERSON_T$4.CURRENT_FLAG = 'Y' AND NED_PERSON_T$4.UNIQUEIDENTIFIER = P.LBO_CHF_DIR_NED_ID
            ) IS NOT NULL THEN 'Y'
         ELSE 'N'
      END AS INACTIVE_LBO, 
      CASE 
         WHEN (EXISTS 
            (
               SELECT PLAN_STATUS_T$6.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$6
               WHERE 
                  PLAN_STATUS_T$6.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$6.STATUS_ID = 246 AND 
                  PLAN_STATUS_T$6.ROLE_ID = 100
            ) OR 
            (
               SELECT SSMAROWNUM$4.ACTIVITY
               FROM 
                  (
                     SELECT ACTIVITY, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$4.ACTIVITY, fci$4.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T$3.PLAN_ID, PLAN_WORKFLOW_T$3.ACTIVITY
                                 FROM IDP.PLAN_WORKFLOW_T  AS PLAN_WORKFLOW_T$3
                                 WHERE PLAN_WORKFLOW_T$3.ACTIVITY IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T$3.ID DESC
                              )  AS fci$4
                           WHERE fci$4.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$4
                  )  AS SSMAROWNUM$4
               WHERE SSMAROWNUM$4.PLAN_ID = P.ID AND SSMAROWNUM$4.ROWNUM = 1
            ) = 278) AND 
            (
               SELECT SSMAROWNUM.MEETING_VERIFIC_DATE
               FROM 
                  (
                     SELECT MEETING_VERIFIC_DATE, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci.MEETING_VERIFIC_DATE, fci.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PWT.PLAN_ID, PWT.MEETING_VERIFIC_DATE
                                 FROM IDP.PLAN_WORKFLOW_T  AS PWT
                                 WHERE PWT.ROLE_ID = 100 AND PWT.MEETING_VERIFIC_DATE IS NOT NULL
                                 ORDER BY PWT.ID DESC
                              )  AS fci
                           WHERE fci.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO
                  )  AS SSMAROWNUM
               WHERE SSMAROWNUM.PLAN_ID = P.ID AND SSMAROWNUM.ROWNUM < 2
            ) != 
            (
               SELECT SSMAROWNUM$2.MEETING_VERIFIC_DATE
               FROM 
                  (
                     SELECT MEETING_VERIFIC_DATE, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$2.MEETING_VERIFIC_DATE, fci$2.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T.PLAN_ID, PLAN_WORKFLOW_T.MEETING_VERIFIC_DATE
                                 FROM IDP.PLAN_WORKFLOW_T
                                 WHERE PLAN_WORKFLOW_T.ROLE_ID = 103 AND PLAN_WORKFLOW_T.MEETING_VERIFIC_DATE IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T.ID DESC
                              )  AS fci$2
                           WHERE fci$2.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$2
                  )  AS SSMAROWNUM$2
               WHERE SSMAROWNUM$2.PLAN_ID = P.ID AND SSMAROWNUM$2.ROWNUM < 2
            ) THEN 'Y'
         ELSE 'N'
      END AS DIFF_MEETING_DATE, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$2.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$2
               WHERE 
                  PLAN_STATUS_T$2.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$2.STATUS_ID = 233 AND 
                  PLAN_STATUS_T$2.ROLE_ID = 100
            ) AND 
            (
               SELECT SSMAROWNUM$3.ACTIVITY
               FROM 
                  (
                     SELECT ACTIVITY, PLAN_ID, ROW_NUMBER() OVER(
                        ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                     FROM 
                        (
                           SELECT fci$3.ACTIVITY, fci$3.PLAN_ID, 0 AS SSMAPSEUDOCOLUMN
                           FROM 
                              (
                                 SELECT TOP 9223372036854775807 PLAN_WORKFLOW_T$2.PLAN_ID, PLAN_WORKFLOW_T$2.ACTIVITY
                                 FROM IDP.PLAN_WORKFLOW_T  AS PLAN_WORKFLOW_T$2
                                 WHERE PLAN_WORKFLOW_T$2.ACTIVITY IS NOT NULL
                                 ORDER BY PLAN_WORKFLOW_T$2.ID DESC
                              )  AS fci$3
                           WHERE fci$3.PLAN_ID = P.ID AND 1 = 1
                        )  AS SSMAPSEUDO$3
                  )  AS SSMAROWNUM$3
               WHERE SSMAROWNUM$3.PLAN_ID = P.ID AND SSMAROWNUM$3.ROWNUM = 1
            ) = 265 THEN 'Y'
         ELSE 'N'
      END AS DECLINED_BY_PM, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT PLAN_STATUS_T$3.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$3
               WHERE 
                  PLAN_STATUS_T$3.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$3.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$3.STATUS_ID IN ( 233, 36, 234 )
            ) AND 
            EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T.ID
               FROM IDP.PLAN_SENT_COUNTER_T
               WHERE 
                  PLAN_SENT_COUNTER_T.PLAN_ID = P.ID AND 
                  PLAN_SENT_COUNTER_T.TO_MENTOR = 4 AND 
                  PLAN_SENT_COUNTER_T.TO_TRAINEE = 4
            ) AND 
            EXISTS 
            (
               SELECT PAGE_STATUS_T.ID
               FROM IDP.PAGE_STATUS_T
               WHERE 
                  PAGE_STATUS_T.PLAN_ID = P.ID AND 
                  (PAGE_STATUS_T.ROLE_ID = 100 OR PAGE_STATUS_T.ROLE_ID = 103) AND 
                  PAGE_STATUS_T.STATUS_ID IN ( 248, 249 )
            ) THEN 'Y'
         ELSE 'N'
      END AS MAX_WORKFLOW_LIMIT_REACHED, 
      CASE 
         WHEN 
            (P.CREATED_DATE NOT BETWEEN TS.AWD_PRD_FROM_DT AND TS.AWD_PRD_TO_DT) AND 
            TS.ACTION_TYPE = 'REN' AND 
            EXISTS 
            (
               SELECT STATUSES_T$6.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$6
               WHERE STATUSES_T$6.PLAN_ID = P.ID AND STATUSES_T$6.STATUS_ID = 34
            ) THEN 'Y'
         ELSE 'N'
      END AS REN_AWD_ACT, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$7.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$7
               WHERE STATUSES_T$7.PLAN_ID = P.ID AND STATUSES_T$7.STATUS_ID = 34
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.HI_EDUCATION_CD IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID != 
            (
               SELECT L$2.ID
               FROM IDP.LOOKUP_T  AS L$2
               WHERE L$2.CODE = CAST(TS.HI_EDUCATION_CD AS varchar(20))
            )) THEN 'Y'
         WHEN EXISTS 
            (
               SELECT STATUSES_T$8.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$8
               WHERE STATUSES_T$8.PLAN_ID = P.ID AND STATUSES_T$8.STATUS_ID = 34
            ) AND (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.HI_EDUCATION_CD IS NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL) THEN 'Y'
         ELSE 'N'
      END AS HI_DEG_FLAG, 
      CASE 
         WHEN 
            EXISTS 
            (
               SELECT STATUSES_T$9.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$9
               WHERE STATUSES_T$9.PLAN_ID = P.ID AND STATUSES_T$9.STATUS_ID = 34
            ) AND 
            P.IS_READY_FOR_SUBMISSION != 'N' AND 
            (
            TS.ORGANIZATIONALSTAT = 'FELLOW' AND 
            TS.TRAIN_PROG_START_DT IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID != 
            (
               SELECT L$3.ID
               FROM IDP.LOOKUP_T  AS L$3
               WHERE L$3.DISCRIMINATOR = 'CURRENT_YEAR_OF_TRAINING' AND L$3.DISPLAY_ORDER_NUM = ceiling(dbo.datediff(sysdatetime(), TS.TRAIN_PROG_START_DT) / 365)
            )) THEN 'Y'
         ELSE 'N'
      END AS CURR_YR_TRAINING_FLAG, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$4.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$4
               WHERE 
                  PLAN_STATUS_T$4.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$4.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$4.STATUS_ID IN (  280 )
            ) AND EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T$2.ID
               FROM IDP.PLAN_SENT_COUNTER_T  AS PLAN_SENT_COUNTER_T$2
               WHERE 
                  PLAN_SENT_COUNTER_T$2.PLAN_ID = P.ID AND 
                  PLAN_SENT_COUNTER_T$2.TO_MENTOR = 4 AND 
                  PLAN_SENT_COUNTER_T$2.TO_TRAINEE = 4
            ) THEN 'Y'
         ELSE 'N'
      END AS ON_HOLD, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_STATUS_T$5.ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$5
               WHERE 
                  PLAN_STATUS_T$5.ROLE_ID = 100 AND 
                  PLAN_STATUS_T$5.PLAN_ID = P.ID AND 
                  PLAN_STATUS_T$5.STATUS_ID IN (  280 )
            ) AND NOT EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T$3.ID
               FROM IDP.PLAN_SENT_COUNTER_T  AS PLAN_SENT_COUNTER_T$3
               WHERE PLAN_SENT_COUNTER_T$3.PLAN_ID = P.ID
            ) THEN 'Y'
         ELSE 'N'
      END AS ON_HOLD_CO_PI
   FROM IDP.PLANS_T  AS P, IDP.NVISION_TRAINEES_T  AS TS, IDP.NED_PERSON_T  AS NED
   WHERE 
      P.TRAINEE_NED_ID = TS.NED_ID AND 
      TS.NED_ID = NED.UNIQUEIDENTIFIER AND 
      P.CURRENT_FLAG = 'Y' AND 
      /*       AND ts.plan_id IS NOT NULL*/NED.CURRENT_FLAG = 'Y' AND 
      TS.NED_ACTIVE_IND = 'Y' AND 
      NED.ORGANIZATIONALSTAT IN ( 'EMPLOYEE', 'FELLOW' )
GO

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

/****** Object:  View [IDP].[TRAINEE_SEARCH_VW]    Script Date: 2/23/2024 3:11:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [IDP].[TRAINEE_SEARCH_VW] (
   NED_ID, 
   FIRST_NAME, 
   MIDDLE_NAME, 
   LAST_NAME, 
   MIXCASE_FIRST_NAME, 
   MIXCASE_MIDDLE_NAME, 
   MIXCASE_LAST_NAME, 
   GENDER_CD, 
   GENDER_DESC, 
   HI_EDUCATION_CD, 
   HI_EDUCATION_DESC, 
   CITIZENSHIP_DESC, 
   NIH_EOD, 
   NIHSERVAO, 
   NIHSAC, 
   AWD_PRD_FROM_DT, 
   AWD_PRD_TO_DT, 
   PLAN_AWD_PRD_FROM_DT, 
   PLAN_AWD_PRD_TO_DT, 
   TRAIN_PROG_CD, 
   TRAIN_PROG_DESC, 
   VISA_TYPE, 
   AWARD_LINE_TYPE, 
   ACTIVATION_DT, 
   NED_ACTIVE_IND, 
   NIHORGPATH, 
   NIHORGACRONYM, 
   ORGANIZATIONALSTAT, 
   PLAN_CREATED_BY, 
   PLAN_CREATED_NAME, 
   PLAN_CREATED_EMAIL, 
   PLAN_LAST_CHANGED_BY, 
   PLAN_LAST_CHANGED_DATE, 
   PLAN_STATUS, 
   IDP_TYPE, 
   TRAINING_ORGANIZATION, 
   TRAINING_ORGANIZATION_PATH, 
   PLAN_ID, 
   INITIATION_DATE, 
   EMAIL_ADDRESS, 
   LAST_REMINDER_DATE, 
   PREFERRED_FIRST_NAME, 
   PREFERRED_LAST_NAME, 
   LBO_ORG_PATH, 
   LBO_NIHSAC, 
   CURRENT_YEAR_OF_TRAINING_ID, 
   CURRENT_TRAINING_TITLE_ID, 
   LBO_CHF_DIR_NED_ID, 
   LBO_CHF_NAME, 
   LBO_CHF_EMAIL, 
   HIGHEST_ED_MAPPED, 
   PRIMARY_MENTOR_NED_ID, 
   CURRENT_PLAN, 
   ESTIMATED_ACTION_DATE, 
   ESTIMATED_COMPLETION_DATE, 
   ON_HOLD, 
   ON_HOLD_CO_PI, 
   TERMINATION_DT, 
   ACT_EFF_DT, 
   TERMINATION_FLG, 
   TRAIN_DIREC_NED_ID, 
   IS_PARTICIPATING_ORG, 
   COUNTER_INFO, 
   GEN_INFO_PAGE_STATUS, 
   PROJ_PAGE_STATUS, 
   CAREER_PAGE_STATUS, 
   ALIGN_PAGE_STATUS, 
   MENTOR_EXPEC_PAGE_STATUS, 
   HI_DEG_FLAG, 
   CURR_YR_TRAIN_FLAG, 
   NVISION_CURR_YR_TRAIN, 
   NVISION_CURR_YR_TRAIN_ID, 
   IS_EXIT_SURVEY_SENT, 
   IS_READY_FOR_SUBMISSION, 
   RACE_WHITE_FLAG, 
   RACE_BL_AA_FLAG, 
   RACE_AI_AN_FLAG, 
   RACE_ASIAN_FLAG, 
   RACE_NH_PI_FLAG, 
   HISPANIC_LATINO_FLAG, 
   GENDER_CODE, 
   DELIVERABLE_PUBLICATION_FLAG, 
   DELIVERABLE_PRESENTATION_FLAG, 
   DELIVERABLE_AWARD_FLAG, 
   DELIVERABLE_OTHER_FLAG, 
   TRNACTV_CLASSES_COURSES_FLAG, 
   TRNACTV_INTEREST_WORKGRP_FLAG, 
   TRNACTV_OTHER_FLAG, 
   GOAL_ACADEMIA_ADMIN_FLAG, 
   GOAL_ACADEMIA_COMM_FLAG, 
   GOAL_ACADEMIA_CLIN_FLAG, 
   GOAL_ACADEMIA_INTLPROP_FLAG, 
   GOAL_ACADEMIA_RESEARCH_FLAG, 
   GOAL_ACADEMIA_PROJMGMT_FLAG, 
   GOAL_ACADEMIA_POLICY_FLAG, 
   GOAL_ACADEMIA_TEACHING_FLAG, 
   GOAL_ACADEMIA_OTHER_FLAG, 
   GOAL_GOVT_ADMIN_FLAG, 
   GOAL_GOVT_COMM_FLAG, 
   GOAL_GOVT_CLIN_FLAG, 
   GOAL_GOVT_INTLPROP_FLAG, 
   GOAL_GOVT_RESEARCH_FLAG, 
   GOAL_GOVT_PROJMGMT_FLAG, 
   GOAL_GOVT_POLICY_FLAG, 
   GOAL_GOVT_OTHER_FLAG, 
   GOAL_PROFIT_ADMIN_FLAG, 
   GOAL_PROFIT_CONSULT_FLAG, 
   GOAL_PROFIT_COMM_FLAG, 
   GOAL_PROFIT_CLIN_FLAG, 
   GOAL_PROFIT_INTLPROP_FLAG, 
   GOAL_PROFIT_RESEARCH_FLAG, 
   GOAL_PROFIT_PROJMGMT_FLAG, 
   GOAL_PROFIT_POLICY_FLAG, 
   GOAL_PROFIT_OTHER_FLAG, 
   GOAL_NONPROFIT_ADMIN_FLAG, 
   GOAL_NONPROFIT_CONSULT_FLAG, 
   GOAL_NONPROFIT_COMM_FLAG, 
   GOAL_NONPROFIT_CLIN_FLAG, 
   GOAL_NONPROFIT_INTLPROP_FLAG, 
   GOAL_NONPROFIT_RESEARCH_FLAG, 
   GOAL_NONPROFIT_PROJMGMT_FLAG, 
   GOAL_NONPROFIT_POLICY_FLAG, 
   GOAL_NONPROFIT_OTHER_FLAG, 
   GOAL_OTHER_ADMIN_FLAG, 
   GOAL_OTHER_CONSULT_FLAG, 
   GOAL_OTHER_COMM_FLAG, 
   GOAL_OTHER_CLIN_FLAG, 
   GOAL_OTHER_INTLPROP_FLAG, 
   GOAL_OTHER_RESEARCH_FLAG, 
   GOAL_OTHER_PROJMGMT_FLAG, 
   GOAL_OTHER_POLICY_FLAG, 
   GOAL_OTHER_TEACHING_FLAG, 
   GOAL_OTHER_OTHER_FLAG, 
   CAREEREXPTR_CAREEREXPNTWK_FLAG, 
   CAREEREXPTR_SK_COMM_FLAG, 
   CAREEREXPTR_SK_ETHICS_FLAG, 
   CAREEREXPTR_SK_GRANTWR_FLAG, 
   CAREEREXPTR_SK_LEADMGMT_FLAG, 
   CAREEREXPTR_SK_MANDTRN_FLAG, 
   CAREEREXPTR_SK_MENTOR_FLAG, 
   CAREEREXPTR_SK_SCMNSCRPT_FLAG, 
   CAREEREXPTR_SK_OTHERS_FLAG, 
   CAREEREXPTR_JOBSEARCH_FLAG, 
   CAREEREXPTR_OTHERS_FLAG)
AS 
   /*
   *   SSMA warning messages:
   *   O2SS0212: Hint FIRST_ROWS with invalid format cannot be converted:  FIRST_ROWS .
   */

   SELECT 
      NV.NED_ID, 
      NV.FIRST_NAME, 
      NV.MIDDLE_NAME, 
      NV.LAST_NAME, 
      NV.MIXCASE_FIRST_NAME AS MIXCASE_FIRST_NAME, 
      NV.MIXCASE_MIDDLE_NAME AS MIXCASE_MIDDLE_NAME, 
      NV.MIXCASE_LAST_NAME AS MIXCASE_LAST_NAME, 
      NV.GENDER_CD, 
      NV.GENDER_DESC, 
      NV.HI_EDUCATION_CD, 
      NV.HI_EDUCATION_DESC, 
      NV.CITIZENSHIP_DESC, 
      NV.NIH_EOD, 
      NV.NIHSERVAO, 
      NV.NIHSAC, 
      NV.AWD_PRD_FROM_DT, 
      NV.AWD_PRD_TO_DT, 
      P.CURRENT_AWARD_DATE_FROM, 
      P.CURRENT_AWARD_DATE_TO, 
      NV.TRAIN_PROG_CD, 
      NV.TRAIN_PROG_DESC, 
      NV.VISA_TYPE, 
      NV.AWARD_LINE_TYPE, 
      NV.ACTIVATION_DT, 
      NV.NED_ACTIVE_IND, 
      NV.NIHORGPATH, 
      NV.NIHORGACRONYM, 
      NV.ORGANIZATIONALSTAT, 
      P.CREATED_BY AS PLAN_CREATED_BY, 
      P.PLAN_CREATED_FULL_NAME, 
      CASE 
         WHEN P.CREATED_BY IS NULL THEN NULL
         ELSE 
            (
               SELECT NED_PERSON_T.MAIL
               FROM IDP.NED_PERSON_T
               WHERE NED_PERSON_T.UNIQUEIDENTIFIER = P.CREATED_BY AND NED_PERSON_T.CURRENT_FLAG = 'Y'
            )
      END AS PLAN_CREATED_BY_EMAIL, 
      P.LAST_CHANGED_BY AS PLAN_LAST_CHANGED_BY, 
      P.LAST_CHANGED_DATE AS PLAN_LAST_CHANGED_DATE, 
      /*status_look.description*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE 
            (
               SELECT L.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L
               WHERE L.ID = 
                  (
                     SELECT PS.STATUS_ID
                     FROM IDP.PLAN_STATUS_T  AS PS
                     WHERE PS.PLAN_ID = P.ID AND PS.ROLE_ID = 100
                  )
            )
      END AS PLAN_STATUS, 
      IDP_LOOK.DESCRIPTION AS IDP_TYPE, 
      P.NCI_DOC_NIHSAC AS TRAINING_ORGANIZATION, 
      P.NCI_DOC_ORG_PATH AS TRAINING_ORGANIZATION_PATH, 
      P.ID AS PLAN_ID, 
      P.TRAINING_PLAN_INITIATION_DATE AS INITIATION_DATE, 
      NV.EMAIL_ADDRESS, 
      CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE 
            (
               SELECT max(MAIL_HISTORY_T.SENT_DATE) AS expr
               FROM IDP.MAIL_HISTORY_T
               WHERE MAIL_HISTORY_T.PLAN_ID = P.ID
            )
      END AS LAST_REMINDER_DATE, 
      NV.PREFERRED_FIRST_NAME, 
      NV.PREFERRED_LAST_NAME, 
      P.LBO_ORG_PATH, 
      P.LBO_NIHSAC, 
      P.CURRENT_YEAR_OF_TRAINING_ID, 
      P.CURRENT_TRAINING_TITLE_ID, 
      P.LBO_CHF_DIR_NED_ID, 
      P.LBO_CHF_DIR_NAME, 
      CASE 
         WHEN P.LBO_CHF_DIR_NED_ID IS NULL THEN NULL
         ELSE 
            (
               SELECT NED_PERSON_T$2.MAIL
               FROM IDP.NED_PERSON_T  AS NED_PERSON_T$2
               WHERE NED_PERSON_T$2.UNIQUEIDENTIFIER = P.LBO_CHF_DIR_NED_ID AND NED_PERSON_T$2.CURRENT_FLAG = 'Y'
            )
      END AS LBO_CHF_EMAIL, 
      CASE 
         WHEN NV.TRAIN_PROG_CD IS NULL THEN 'N'
         WHEN EXISTS 
            (
               SELECT 
                  T.HIGHEST_DEGREE_FPS_ID, 
                  T.TRAINING_TITLE_FPS_ID, 
                  T.CREATED_BY, 
                  T.CREATED_DATE, 
                  T.LAST_CHANGED_BY, 
                  T.LAST_CHANGED_DATE
               FROM IDP.DEGREE_TRAIN_TITLE_MAPPING_T  AS T, IDP.LOOKUP_T  AS L0
               WHERE NV.TRAIN_PROG_CD = L0.CODE AND L0.ID = T.TRAINING_TITLE_FPS_ID
            ) THEN 'Y'
         ELSE 'N'
      END AS HIGHEST_ED_MAPPED, 
      CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE 
            (
               SELECT M.MENTOR_NED_ID
               FROM IDP.MENTORS_T  AS M
               WHERE M.PRIMARY_MENTOR_FLAG = 'Y' AND M.PLAN_ID = P.ID
            )
      END AS PRIMARY_MENTOR_NED_ID, 
      P.CURRENT_FLAG AS CURRENT_PLAN, 
      P.ESTIMATED_ACTION_DATE, 
      P.ESTIMATED_COMPLETION_DATE, 
      P.ON_HOLD, 
      P.ON_HOLD_CO_PI, 
      NV.TERMINATION_DT, 
      NV.ACT_EFF_DT, 
      NV.TERMINATION_FLG, 
      CASE 
         WHEN P.ID IS NOT NULL THEN 
            (
               SELECT DOCS_VW.TRAINING_DIRECTOR_NED_ID
               FROM IDP.DOCS_VW
               WHERE DOCS_VW.NIHSAC = P.NED_NIHSAC
            )
         ELSE NULL
      END AS TRAIN_DIREC_NED_ID, 
      CASE 
         WHEN EXISTS 
            (
               SELECT DOCS.NIHSAC
               FROM IDP.DOCS_VW  AS DOCS
               WHERE NV.NIHSAC LIKE (ISNULL(DOCS.NIHSAC, '') + '%') AND DOCS.PARTICIPATING_ORG_ACTIVE_FLAG = 'Y'
            ) THEN 'Y'
         ELSE 'N'
      END AS IS_PARTICIPATING_ORG, 
      CASE 
         WHEN EXISTS 
            (
               SELECT PLAN_SENT_COUNTER_T.ID
               FROM IDP.PLAN_SENT_COUNTER_T
               WHERE PLAN_SENT_COUNTER_T.PLAN_ID = P.ID
            ) THEN 'N'
         ELSE 'Y'
      END, 
      CASE 
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T.STATUS_ID
               FROM IDP.PLAN_STATUS_T
               WHERE PLAN_STATUS_T.PLAN_ID = P.ID AND PLAN_STATUS_T.ROLE_ID = 100
            ) = 36 THEN 
            (
               SELECT L$2.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$2
               WHERE L$2.ID = 
                  (
                     SELECT SSMAROWNUM.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$2.STATUS_ID, 
                                    PS$2.PAGE_ID, 
                                    PS$2.PLAN_ID, 
                                    PS$2.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$2
                                 WHERE 
                                    PS$2.PAGE_ID = 192 AND 
                                    PS$2.PLAN_ID = P.ID AND 
                                    PS$2.ROLE_ID = 103 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO
                        )  AS SSMAROWNUM
                     WHERE 
                        SSMAROWNUM.PAGE_ID = 192 AND 
                        SSMAROWNUM.PLAN_ID = P.ID AND 
                        SSMAROWNUM.ROLE_ID = 103 AND 
                        SSMAROWNUM.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$2.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$2
               WHERE PLAN_STATUS_T$2.PLAN_ID = P.ID AND PLAN_STATUS_T$2.ROLE_ID = 100
            ) = 236 THEN 
            (
               SELECT L$3.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$3
               WHERE L$3.ID = 
                  (
                     SELECT SSMAROWNUM$2.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$3.STATUS_ID, 
                                    PS$3.PAGE_ID, 
                                    PS$3.PLAN_ID, 
                                    PS$3.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$3
                                 WHERE 
                                    PS$3.PAGE_ID = 192 AND 
                                    PS$3.PLAN_ID = P.ID AND 
                                    PS$3.ROLE_ID = 101 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$2
                        )  AS SSMAROWNUM$2
                     WHERE 
                        SSMAROWNUM$2.PAGE_ID = 192 AND 
                        SSMAROWNUM$2.PLAN_ID = P.ID AND 
                        SSMAROWNUM$2.ROLE_ID = 101 AND 
                        SSMAROWNUM$2.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$3.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$3
               WHERE PLAN_STATUS_T$3.PLAN_ID = P.ID AND PLAN_STATUS_T$3.ROLE_ID = 100
            ) = 246 THEN 
            (
               SELECT L$4.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$4
               WHERE L$4.ID = 
                  (
                     SELECT SSMAROWNUM$3.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$4.STATUS_ID, 
                                    PS$4.PAGE_ID, 
                                    PS$4.PLAN_ID, 
                                    PS$4.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$4
                                 WHERE 
                                    PS$4.PAGE_ID = 192 AND 
                                    PS$4.PLAN_ID = P.ID AND 
                                    PS$4.ROLE_ID = 104 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$3
                        )  AS SSMAROWNUM$3
                     WHERE 
                        SSMAROWNUM$3.PAGE_ID = 192 AND 
                        SSMAROWNUM$3.PLAN_ID = P.ID AND 
                        SSMAROWNUM$3.ROLE_ID = 104 AND 
                        SSMAROWNUM$3.ROWNUM = 1
                  )
            )
         ELSE NULL
      END AS GEN_INFO_PAGE_STATUS, 
      CASE 
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$4.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$4
               WHERE PLAN_STATUS_T$4.PLAN_ID = P.ID AND PLAN_STATUS_T$4.ROLE_ID = 100
            ) = 36 THEN 
            (
               SELECT L$5.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$5
               WHERE L$5.ID = 
                  (
                     SELECT SSMAROWNUM$4.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$5.STATUS_ID, 
                                    PS$5.PAGE_ID, 
                                    PS$5.PLAN_ID, 
                                    PS$5.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$5
                                 WHERE 
                                    PS$5.PAGE_ID = 193 AND 
                                    PS$5.PLAN_ID = P.ID AND 
                                    PS$5.ROLE_ID = 103 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$4
                        )  AS SSMAROWNUM$4
                     WHERE 
                        SSMAROWNUM$4.PAGE_ID = 193 AND 
                        SSMAROWNUM$4.PLAN_ID = P.ID AND 
                        SSMAROWNUM$4.ROLE_ID = 103 AND 
                        SSMAROWNUM$4.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$5.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$5
               WHERE PLAN_STATUS_T$5.PLAN_ID = P.ID AND PLAN_STATUS_T$5.ROLE_ID = 100
            ) = 236 THEN 
            (
               SELECT L$6.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$6
               WHERE L$6.ID = 
                  (
                     SELECT SSMAROWNUM$5.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$6.STATUS_ID, 
                                    PS$6.PAGE_ID, 
                                    PS$6.PLAN_ID, 
                                    PS$6.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$6
                                 WHERE 
                                    PS$6.PAGE_ID = 193 AND 
                                    PS$6.PLAN_ID = P.ID AND 
                                    PS$6.ROLE_ID = 101 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$5
                        )  AS SSMAROWNUM$5
                     WHERE 
                        SSMAROWNUM$5.PAGE_ID = 193 AND 
                        SSMAROWNUM$5.PLAN_ID = P.ID AND 
                        SSMAROWNUM$5.ROLE_ID = 101 AND 
                        SSMAROWNUM$5.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$6.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$6
               WHERE PLAN_STATUS_T$6.PLAN_ID = P.ID AND PLAN_STATUS_T$6.ROLE_ID = 100
            ) = 246 THEN 
            (
               SELECT L$7.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$7
               WHERE L$7.ID = 
                  (
                     SELECT SSMAROWNUM$6.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$7.STATUS_ID, 
                                    PS$7.PAGE_ID, 
                                    PS$7.PLAN_ID, 
                                    PS$7.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$7
                                 WHERE 
                                    PS$7.PAGE_ID = 193 AND 
                                    PS$7.PLAN_ID = P.ID AND 
                                    PS$7.ROLE_ID = 104 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$6
                        )  AS SSMAROWNUM$6
                     WHERE 
                        SSMAROWNUM$6.PAGE_ID = 193 AND 
                        SSMAROWNUM$6.PLAN_ID = P.ID AND 
                        SSMAROWNUM$6.ROLE_ID = 104 AND 
                        SSMAROWNUM$6.ROWNUM = 1
                  )
            )
         ELSE NULL
      END AS PROJ_PAGE_STATUS, 
      CASE 
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$7.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$7
               WHERE PLAN_STATUS_T$7.PLAN_ID = P.ID AND PLAN_STATUS_T$7.ROLE_ID = 100
            ) = 36 THEN 
            (
               SELECT L$8.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$8
               WHERE L$8.ID = 
                  (
                     SELECT SSMAROWNUM$7.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$8.STATUS_ID, 
                                    PS$8.PAGE_ID, 
                                    PS$8.PLAN_ID, 
                                    PS$8.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$8
                                 WHERE 
                                    PS$8.PAGE_ID = 194 AND 
                                    PS$8.PLAN_ID = P.ID AND 
                                    PS$8.ROLE_ID = 103 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$7
                        )  AS SSMAROWNUM$7
                     WHERE 
                        SSMAROWNUM$7.PAGE_ID = 194 AND 
                        SSMAROWNUM$7.PLAN_ID = P.ID AND 
                        SSMAROWNUM$7.ROLE_ID = 103 AND 
                        SSMAROWNUM$7.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$8.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$8
               WHERE PLAN_STATUS_T$8.PLAN_ID = P.ID AND PLAN_STATUS_T$8.ROLE_ID = 100
            ) = 236 THEN 
            (
               SELECT L$9.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$9
               WHERE L$9.ID = 
                  (
                     SELECT SSMAROWNUM$8.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$9.STATUS_ID, 
                                    PS$9.PAGE_ID, 
                                    PS$9.PLAN_ID, 
                                    PS$9.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$9
                                 WHERE 
                                    PS$9.PAGE_ID = 194 AND 
                                    PS$9.PLAN_ID = P.ID AND 
                                    PS$9.ROLE_ID = 101 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$8
                        )  AS SSMAROWNUM$8
                     WHERE 
                        SSMAROWNUM$8.PAGE_ID = 194 AND 
                        SSMAROWNUM$8.PLAN_ID = P.ID AND 
                        SSMAROWNUM$8.ROLE_ID = 101 AND 
                        SSMAROWNUM$8.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$9.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$9
               WHERE PLAN_STATUS_T$9.PLAN_ID = P.ID AND PLAN_STATUS_T$9.ROLE_ID = 100
            ) = 246 THEN 
            (
               SELECT L$10.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$10
               WHERE L$10.ID = 
                  (
                     SELECT SSMAROWNUM$9.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$10.STATUS_ID, 
                                    PS$10.PAGE_ID, 
                                    PS$10.PLAN_ID, 
                                    PS$10.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$10
                                 WHERE 
                                    PS$10.PAGE_ID = 194 AND 
                                    PS$10.PLAN_ID = P.ID AND 
                                    PS$10.ROLE_ID = 104 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$9
                        )  AS SSMAROWNUM$9
                     WHERE 
                        SSMAROWNUM$9.PAGE_ID = 194 AND 
                        SSMAROWNUM$9.PLAN_ID = P.ID AND 
                        SSMAROWNUM$9.ROLE_ID = 104 AND 
                        SSMAROWNUM$9.ROWNUM = 1
                  )
            )
         ELSE NULL
      END AS CAREER_PAGE_STATUS, 
      CASE 
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$10.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$10
               WHERE PLAN_STATUS_T$10.PLAN_ID = P.ID AND PLAN_STATUS_T$10.ROLE_ID = 100
            ) = 36 THEN 
            (
               SELECT L$11.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$11
               WHERE L$11.ID = 
                  (
                     SELECT SSMAROWNUM$10.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$11.STATUS_ID, 
                                    PS$11.PAGE_ID, 
                                    PS$11.PLAN_ID, 
                                    PS$11.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$11
                                 WHERE 
                                    PS$11.PAGE_ID = 195 AND 
                                    PS$11.PLAN_ID = P.ID AND 
                                    PS$11.ROLE_ID = 103 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$10
                        )  AS SSMAROWNUM$10
                     WHERE 
                        SSMAROWNUM$10.PAGE_ID = 195 AND 
                        SSMAROWNUM$10.PLAN_ID = P.ID AND 
                        SSMAROWNUM$10.ROLE_ID = 103 AND 
                        SSMAROWNUM$10.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$11.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$11
               WHERE PLAN_STATUS_T$11.PLAN_ID = P.ID AND PLAN_STATUS_T$11.ROLE_ID = 100
            ) = 236 THEN 
            (
               SELECT L$12.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$12
               WHERE L$12.ID = 
                  (
                     SELECT SSMAROWNUM$11.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$12.STATUS_ID, 
                                    PS$12.PAGE_ID, 
                                    PS$12.PLAN_ID, 
                                    PS$12.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$12
                                 WHERE 
                                    PS$12.PAGE_ID = 195 AND 
                                    PS$12.PLAN_ID = P.ID AND 
                                    PS$12.ROLE_ID = 101 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$11
                        )  AS SSMAROWNUM$11
                     WHERE 
                        SSMAROWNUM$11.PAGE_ID = 195 AND 
                        SSMAROWNUM$11.PLAN_ID = P.ID AND 
                        SSMAROWNUM$11.ROLE_ID = 101 AND 
                        SSMAROWNUM$11.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$12.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$12
               WHERE PLAN_STATUS_T$12.PLAN_ID = P.ID AND PLAN_STATUS_T$12.ROLE_ID = 100
            ) = 246 THEN 
            (
               SELECT L$13.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$13
               WHERE L$13.ID = 
                  (
                     SELECT SSMAROWNUM$12.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$13.STATUS_ID, 
                                    PS$13.PAGE_ID, 
                                    PS$13.PLAN_ID, 
                                    PS$13.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$13
                                 WHERE 
                                    PS$13.PAGE_ID = 195 AND 
                                    PS$13.PLAN_ID = P.ID AND 
                                    PS$13.ROLE_ID = 104 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$12
                        )  AS SSMAROWNUM$12
                     WHERE 
                        SSMAROWNUM$12.PAGE_ID = 195 AND 
                        SSMAROWNUM$12.PLAN_ID = P.ID AND 
                        SSMAROWNUM$12.ROLE_ID = 104 AND 
                        SSMAROWNUM$12.ROWNUM = 1
                  )
            )
         ELSE NULL
      END AS ALIGN_PAGE_STATUS, 
      CASE 
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$13.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$13
               WHERE PLAN_STATUS_T$13.PLAN_ID = P.ID AND PLAN_STATUS_T$13.ROLE_ID = 100
            ) = 36 THEN 
            (
               SELECT L$14.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$14
               WHERE L$14.ID = 
                  (
                     SELECT SSMAROWNUM$13.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$14.STATUS_ID, 
                                    PS$14.PAGE_ID, 
                                    PS$14.PLAN_ID, 
                                    PS$14.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$14
                                 WHERE 
                                    PS$14.PAGE_ID = 196 AND 
                                    PS$14.PLAN_ID = P.ID AND 
                                    PS$14.ROLE_ID = 103 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$13
                        )  AS SSMAROWNUM$13
                     WHERE 
                        SSMAROWNUM$13.PAGE_ID = 196 AND 
                        SSMAROWNUM$13.PLAN_ID = P.ID AND 
                        SSMAROWNUM$13.ROLE_ID = 103 AND 
                        SSMAROWNUM$13.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$14.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$14
               WHERE PLAN_STATUS_T$14.PLAN_ID = P.ID AND PLAN_STATUS_T$14.ROLE_ID = 100
            ) = 236 THEN 
            (
               SELECT L$15.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$15
               WHERE L$15.ID = 
                  (
                     SELECT SSMAROWNUM$14.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$15.STATUS_ID, 
                                    PS$15.PAGE_ID, 
                                    PS$15.PLAN_ID, 
                                    PS$15.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$15
                                 WHERE 
                                    PS$15.PAGE_ID = 196 AND 
                                    PS$15.PLAN_ID = P.ID AND 
                                    PS$15.ROLE_ID = 101 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$14
                        )  AS SSMAROWNUM$14
                     WHERE 
                        SSMAROWNUM$14.PAGE_ID = 196 AND 
                        SSMAROWNUM$14.PLAN_ID = P.ID AND 
                        SSMAROWNUM$14.ROLE_ID = 101 AND 
                        SSMAROWNUM$14.ROWNUM = 1
                  )
            )
         WHEN P.ID IS NOT NULL AND 
            (
               SELECT PLAN_STATUS_T$15.STATUS_ID
               FROM IDP.PLAN_STATUS_T  AS PLAN_STATUS_T$15
               WHERE PLAN_STATUS_T$15.PLAN_ID = P.ID AND PLAN_STATUS_T$15.ROLE_ID = 100
            ) = 246 THEN 
            (
               SELECT L$16.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$16
               WHERE L$16.ID = 
                  (
                     SELECT SSMAROWNUM$15.STATUS_ID
                     FROM 
                        (
                           SELECT 
                              STATUS_ID, 
                              PAGE_ID, 
                              PLAN_ID, 
                              ROLE_ID, 
                              ROW_NUMBER() OVER(
                                 ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                           FROM 
                              (
                                 SELECT 
                                    PS$16.STATUS_ID, 
                                    PS$16.PAGE_ID, 
                                    PS$16.PLAN_ID, 
                                    PS$16.ROLE_ID, 
                                    0 AS SSMAPSEUDOCOLUMN
                                 FROM IDP.PAGE_STATUS_T  AS PS$16
                                 WHERE 
                                    PS$16.PAGE_ID = 196 AND 
                                    PS$16.PLAN_ID = P.ID AND 
                                    PS$16.ROLE_ID = 104 AND 
                                    1 = 1
                              )  AS SSMAPSEUDO$15
                        )  AS SSMAROWNUM$15
                     WHERE 
                        SSMAROWNUM$15.PAGE_ID = 196 AND 
                        SSMAROWNUM$15.PLAN_ID = P.ID AND 
                        SSMAROWNUM$15.ROLE_ID = 104 AND 
                        SSMAROWNUM$15.ROWNUM = 1
                  )
            )
         ELSE NULL
      END AS MENTOR_EXPEC_PAGE_STATUS, 
      CASE 
         WHEN EXISTS 
            (
               SELECT STATUSES_T.ID
               FROM IDP.STATUSES_T
               WHERE STATUSES_T.PLAN_ID = P.ID AND STATUSES_T.STATUS_ID IN ( 34, 35 )
            ) AND (
            NV.ORGANIZATIONALSTAT = 'FELLOW' AND 
            NV.HI_EDUCATION_CD IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID != 
            (
               SELECT L$19.ID
               FROM IDP.LOOKUP_T  AS L$19
               WHERE L$19.CODE = CAST(NV.HI_EDUCATION_CD AS varchar(20))
            )) THEN 'Y'
         WHEN EXISTS 
            (
               SELECT STATUSES_T$2.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$2
               WHERE STATUSES_T$2.PLAN_ID = P.ID AND STATUSES_T$2.STATUS_ID IN ( 34, 35 )
            ) AND (
            NV.ORGANIZATIONALSTAT = 'FELLOW' AND 
            NV.HI_EDUCATION_CD IS NULL AND 
            P.HIGHEST_DEGREE_OBTAINED_ID IS NOT NULL) THEN 'Y'
         ELSE 'N'
      END, 
      CASE 
         WHEN EXISTS 
            (
               SELECT STATUSES_T$3.ID
               FROM IDP.STATUSES_T  AS STATUSES_T$3
               WHERE STATUSES_T$3.PLAN_ID = P.ID AND STATUSES_T$3.STATUS_ID IN ( 34, 35 )
            ) AND (
            NV.ORGANIZATIONALSTAT = 'FELLOW' AND 
            NV.TRAIN_PROG_START_DT IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID IS NOT NULL AND 
            P.CURRENT_YEAR_OF_TRAINING_ID != 
            (
               SELECT L$20.ID
               FROM IDP.LOOKUP_T  AS L$20
               WHERE L$20.DISCRIMINATOR = 'CURRENT_YEAR_OF_TRAINING' AND L$20.DISPLAY_ORDER_NUM = ceiling(dbo.datediff(sysdatetime(), NV.TRAIN_PROG_START_DT) / 365)
            )) THEN 'Y'
         ELSE 'N'
      END, 
      CASE 
         WHEN NV.ORGANIZATIONALSTAT = 'FELLOW' AND NV.TRAIN_PROG_START_DT IS NOT NULL THEN 
            (
               SELECT L$17.DESCRIPTION
               FROM IDP.LOOKUP_T  AS L$17
               WHERE L$17.DISCRIMINATOR = 'CURRENT_YEAR_OF_TRAINING' AND L$17.DISPLAY_ORDER_NUM = ceiling(dbo.datediff(sysdatetime(), NV.TRAIN_PROG_START_DT) / 365)
            )
         ELSE NULL
      END, 
      CASE 
         WHEN NV.ORGANIZATIONALSTAT = 'FELLOW' AND NV.TRAIN_PROG_START_DT IS NOT NULL THEN 
            (
               SELECT L$18.ID
               FROM IDP.LOOKUP_T  AS L$18
               WHERE L$18.DISCRIMINATOR = 'CURRENT_YEAR_OF_TRAINING' AND L$18.DISPLAY_ORDER_NUM = ceiling(dbo.datediff(sysdatetime(), NV.TRAIN_PROG_START_DT) / 365)
            )
         ELSE NULL
      END, 
      CASE 
         WHEN EXISTS 
            (
               SELECT SURVEYINFO.ID
               FROM IDP.EXIT_SURVEY_TOKEN_INFO_T  AS SURVEYINFO
               WHERE SURVEYINFO.NED_ID = NV.NED_ID
            ) THEN 'Y'
         ELSE 'N'
      END, 
      CASE 
         WHEN P.IS_READY_FOR_SUBMISSION IS NULL THEN 'Y'
         ELSE P.IS_READY_FOR_SUBMISSION
      END, 
      /* IDP-1105 New columns   RACE_WHITE_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.RACE_WHITE_FLAG
      END, 
      /* RACE_BL_AA_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.RACE_BL_AA_FLAG
      END, 
      /* RACE_AI_AN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.RACE_AI_AN_FLAG
      END, 
      /* RACE_ASIAN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.RACE_ASIAN_FLAG
      END, 
      /* RACE_NH_PI_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.RACE_NH_PI_FLAG
      END, 
      /* HISPANIC_LATINO_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN P.HISPANIC_LATINO_FLAG IS NULL THEN NULL
            ELSE CASE 
               WHEN P.HISPANIC_LATINO_FLAG = '1' THEN 'Y'
               ELSE 'N'
            END
         END
      END, 
      /* GENDER_CODE*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE P.GENDER_CODE
      END, 
      /* DELIVERABLE_PUBLICATION_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     DEL.ID, 
                     DEL.DELIVERABLE_TYPE_ID, 
                     DEL.TITLE, 
                     DEL.DESCRIPTION, 
                     DEL.DATE_FROM, 
                     DEL.LOCATION, 
                     DEL.TRAVELLING_INVOLVED_FLAG, 
                     DEL.SUBTYPE_ID, 
                     DEL.CREATED_BY, 
                     DEL.CREATED_DATE, 
                     DEL.LAST_CHANGED_BY, 
                     DEL.LAST_CHANGED_DATE, 
                     DEL.DATE_TO, 
                     DEL.AWARD_SUBTYPE_ID, 
                     DEL.OTHER_TEXT, 
                     DEL.FUNDING_TYPE, 
                     DEL.MEETCONFNAME, 
                     DEL.DEL_STATUS_ID, 
                     DEL.PARENT_DEL_ID, 
                     DEL.PUB_MED_ID, 
                     DEL.IS_FIRST_AUTHOR, 
                     DEL.PUB_NAME, 
                     DEL.PUB_TITLE, 
                     DEL.PUB_AUTHORS, 
                     DEL.PUB_DATE, 
                     DEL.IS_EDITABLE_STATUS, 
                     DEL.DEL_LAST_CHANGED_DATE, 
                     DEL.AWD_AMT
                  FROM IDP.PROJECT_DELIVERABLES_T  AS PROJDEL, IDP.PROJECTS_T  AS PROJ, IDP.DELIVERABLES_T  AS DEL
                  WHERE 
                     PROJ.PLAN_ID = P.ID AND 
                     PROJDEL.PROJECT_ID = PROJ.ID AND 
                     PROJDEL.DELIVERABLE_ID = DEL.ID AND 
                     DEL.DELIVERABLE_TYPE_ID = 74
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* DELIVERABLE_PRESENTATION_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     DEL$2.ID, 
                     DEL$2.DELIVERABLE_TYPE_ID, 
                     DEL$2.TITLE, 
                     DEL$2.DESCRIPTION, 
                     DEL$2.DATE_FROM, 
                     DEL$2.LOCATION, 
                     DEL$2.TRAVELLING_INVOLVED_FLAG, 
                     DEL$2.SUBTYPE_ID, 
                     DEL$2.CREATED_BY, 
                     DEL$2.CREATED_DATE, 
                     DEL$2.LAST_CHANGED_BY, 
                     DEL$2.LAST_CHANGED_DATE, 
                     DEL$2.DATE_TO, 
                     DEL$2.AWARD_SUBTYPE_ID, 
                     DEL$2.OTHER_TEXT, 
                     DEL$2.FUNDING_TYPE, 
                     DEL$2.MEETCONFNAME, 
                     DEL$2.DEL_STATUS_ID, 
                     DEL$2.PARENT_DEL_ID, 
                     DEL$2.PUB_MED_ID, 
                     DEL$2.IS_FIRST_AUTHOR, 
                     DEL$2.PUB_NAME, 
                     DEL$2.PUB_TITLE, 
                     DEL$2.PUB_AUTHORS, 
                     DEL$2.PUB_DATE, 
                     DEL$2.IS_EDITABLE_STATUS, 
                     DEL$2.DEL_LAST_CHANGED_DATE, 
                     DEL$2.AWD_AMT
                  FROM IDP.PROJECT_DELIVERABLES_T  AS PROJDEL$2, IDP.PROJECTS_T  AS PROJ$2, IDP.DELIVERABLES_T  AS DEL$2
                  WHERE 
                     PROJ$2.PLAN_ID = P.ID AND 
                     PROJDEL$2.PROJECT_ID = PROJ$2.ID AND 
                     PROJDEL$2.DELIVERABLE_ID = DEL$2.ID AND 
                     DEL$2.DELIVERABLE_TYPE_ID = 75
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* DELIVERABLE_AWARD_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     DEL$3.ID, 
                     DEL$3.DELIVERABLE_TYPE_ID, 
                     DEL$3.TITLE, 
                     DEL$3.DESCRIPTION, 
                     DEL$3.DATE_FROM, 
                     DEL$3.LOCATION, 
                     DEL$3.TRAVELLING_INVOLVED_FLAG, 
                     DEL$3.SUBTYPE_ID, 
                     DEL$3.CREATED_BY, 
                     DEL$3.CREATED_DATE, 
                     DEL$3.LAST_CHANGED_BY, 
                     DEL$3.LAST_CHANGED_DATE, 
                     DEL$3.DATE_TO, 
                     DEL$3.AWARD_SUBTYPE_ID, 
                     DEL$3.OTHER_TEXT, 
                     DEL$3.FUNDING_TYPE, 
                     DEL$3.MEETCONFNAME, 
                     DEL$3.DEL_STATUS_ID, 
                     DEL$3.PARENT_DEL_ID, 
                     DEL$3.PUB_MED_ID, 
                     DEL$3.IS_FIRST_AUTHOR, 
                     DEL$3.PUB_NAME, 
                     DEL$3.PUB_TITLE, 
                     DEL$3.PUB_AUTHORS, 
                     DEL$3.PUB_DATE, 
                     DEL$3.IS_EDITABLE_STATUS, 
                     DEL$3.DEL_LAST_CHANGED_DATE, 
                     DEL$3.AWD_AMT
                  FROM IDP.PROJECT_DELIVERABLES_T  AS PROJDEL$3, IDP.PROJECTS_T  AS PROJ$3, IDP.DELIVERABLES_T  AS DEL$3
                  WHERE 
                     PROJ$3.PLAN_ID = P.ID AND 
                     PROJDEL$3.PROJECT_ID = PROJ$3.ID AND 
                     PROJDEL$3.DELIVERABLE_ID = DEL$3.ID AND 
                     DEL$3.DELIVERABLE_TYPE_ID = 76
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* DELIVERABLE_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     DEL$4.ID, 
                     DEL$4.DELIVERABLE_TYPE_ID, 
                     DEL$4.TITLE, 
                     DEL$4.DESCRIPTION, 
                     DEL$4.DATE_FROM, 
                     DEL$4.LOCATION, 
                     DEL$4.TRAVELLING_INVOLVED_FLAG, 
                     DEL$4.SUBTYPE_ID, 
                     DEL$4.CREATED_BY, 
                     DEL$4.CREATED_DATE, 
                     DEL$4.LAST_CHANGED_BY, 
                     DEL$4.LAST_CHANGED_DATE, 
                     DEL$4.DATE_TO, 
                     DEL$4.AWARD_SUBTYPE_ID, 
                     DEL$4.OTHER_TEXT, 
                     DEL$4.FUNDING_TYPE, 
                     DEL$4.MEETCONFNAME, 
                     DEL$4.DEL_STATUS_ID, 
                     DEL$4.PARENT_DEL_ID, 
                     DEL$4.PUB_MED_ID, 
                     DEL$4.IS_FIRST_AUTHOR, 
                     DEL$4.PUB_NAME, 
                     DEL$4.PUB_TITLE, 
                     DEL$4.PUB_AUTHORS, 
                     DEL$4.PUB_DATE, 
                     DEL$4.IS_EDITABLE_STATUS, 
                     DEL$4.DEL_LAST_CHANGED_DATE, 
                     DEL$4.AWD_AMT
                  FROM IDP.PROJECT_DELIVERABLES_T  AS PROJDEL$4, IDP.PROJECTS_T  AS PROJ$4, IDP.DELIVERABLES_T  AS DEL$4
                  WHERE 
                     PROJ$4.PLAN_ID = P.ID AND 
                     PROJDEL$4.PROJECT_ID = PROJ$4.ID AND 
                     PROJDEL$4.DELIVERABLE_ID = DEL$4.ID AND 
                     DEL$4.DELIVERABLE_TYPE_ID = 78
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* TRNACTV_CLASSES_COURSES_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     ACT.ID, 
                     ACT.ACTIVITY_TYPE_ID, 
                     ACT.SUBMISSION_DATE, 
                     ACT.TITLE, 
                     ACT.DESCRIPTION, 
                     ACT.DATE_FROM, 
                     ACT.DATE_TO, 
                     ACT.RECORD_DATE, 
                     ACT.LOCATION, 
                     ACT.SUBTYPE_ID, 
                     ACT.CREATED_BY, 
                     ACT.CREATED_DATE, 
                     ACT.LAST_CHANGED_BY, 
                     ACT.LAST_CHANGED_DATE, 
                     ACT.PLAN_ID, 
                     ACT.TRAVELLING_INVOLVED_FLAG, 
                     ACT.PARENT_ACTIVITY_ID, 
                     ACT.ACT_STATUS_ID, 
                     ACT.TO_PRESENT, 
                     ACT.IS_EDITABLE_STATUS, 
                     ACT.ACT_LAST_CHANGED_DATE
                  FROM IDP.PROJECT_ACTIVITIES_T  AS PROJACT, IDP.PROJECTS_T  AS PROJ$5, IDP.ACTIVITIES_T  AS ACT
                  WHERE 
                     PROJ$5.PLAN_ID = P.ID AND 
                     PROJACT.PROJECT_ID = PROJ$5.ID AND 
                     PROJACT.ACTIVITY_ID = ACT.ID AND 
                     ACT.ACTIVITY_TYPE_ID = 3
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* TRNACTV_INTEREST_WORKGRP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     ACT$2.ID, 
                     ACT$2.ACTIVITY_TYPE_ID, 
                     ACT$2.SUBMISSION_DATE, 
                     ACT$2.TITLE, 
                     ACT$2.DESCRIPTION, 
                     ACT$2.DATE_FROM, 
                     ACT$2.DATE_TO, 
                     ACT$2.RECORD_DATE, 
                     ACT$2.LOCATION, 
                     ACT$2.SUBTYPE_ID, 
                     ACT$2.CREATED_BY, 
                     ACT$2.CREATED_DATE, 
                     ACT$2.LAST_CHANGED_BY, 
                     ACT$2.LAST_CHANGED_DATE, 
                     ACT$2.PLAN_ID, 
                     ACT$2.TRAVELLING_INVOLVED_FLAG, 
                     ACT$2.PARENT_ACTIVITY_ID, 
                     ACT$2.ACT_STATUS_ID, 
                     ACT$2.TO_PRESENT, 
                     ACT$2.IS_EDITABLE_STATUS, 
                     ACT$2.ACT_LAST_CHANGED_DATE
                  FROM IDP.PROJECT_ACTIVITIES_T  AS PROJACT$2, IDP.PROJECTS_T  AS PROJ$6, IDP.ACTIVITIES_T  AS ACT$2
                  WHERE 
                     PROJ$6.PLAN_ID = P.ID AND 
                     PROJACT$2.PROJECT_ID = PROJ$6.ID AND 
                     PROJACT$2.ACTIVITY_ID = ACT$2.ID AND 
                     ACT$2.ACTIVITY_TYPE_ID = 4
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* TRNACTV_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     ACT$3.ID, 
                     ACT$3.ACTIVITY_TYPE_ID, 
                     ACT$3.SUBMISSION_DATE, 
                     ACT$3.TITLE, 
                     ACT$3.DESCRIPTION, 
                     ACT$3.DATE_FROM, 
                     ACT$3.DATE_TO, 
                     ACT$3.RECORD_DATE, 
                     ACT$3.LOCATION, 
                     ACT$3.SUBTYPE_ID, 
                     ACT$3.CREATED_BY, 
                     ACT$3.CREATED_DATE, 
                     ACT$3.LAST_CHANGED_BY, 
                     ACT$3.LAST_CHANGED_DATE, 
                     ACT$3.PLAN_ID, 
                     ACT$3.TRAVELLING_INVOLVED_FLAG, 
                     ACT$3.PARENT_ACTIVITY_ID, 
                     ACT$3.ACT_STATUS_ID, 
                     ACT$3.TO_PRESENT, 
                     ACT$3.IS_EDITABLE_STATUS, 
                     ACT$3.ACT_LAST_CHANGED_DATE
                  FROM IDP.PROJECT_ACTIVITIES_T  AS PROJACT$3, IDP.PROJECTS_T  AS PROJ$7, IDP.ACTIVITIES_T  AS ACT$3
                  WHERE 
                     PROJ$7.PLAN_ID = P.ID AND 
                     PROJACT$3.PROJECT_ID = PROJ$7.ID AND 
                     PROJACT$3.ACTIVITY_ID = ACT$3.ID AND 
                     ACT$3.ACTIVITY_TYPE_ID = 6
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_ADMIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T.ID, 
                     CAREER_GOALS_T.GOAL_ID, 
                     CAREER_GOALS_T.CREATED_BY, 
                     CAREER_GOALS_T.CREATED_DATE, 
                     CAREER_GOALS_T.LAST_CHANGED_BY, 
                     CAREER_GOALS_T.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T.PLAN_ID, 
                     CAREER_GOALS_T.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T
                  WHERE CAREER_GOALS_T.PLAN_ID = P.ID AND CAREER_GOALS_T.GOAL_ID = 39
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$2.ID, 
                     CAREER_GOALS_T$2.GOAL_ID, 
                     CAREER_GOALS_T$2.CREATED_BY, 
                     CAREER_GOALS_T$2.CREATED_DATE, 
                     CAREER_GOALS_T$2.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$2.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$2.PLAN_ID, 
                     CAREER_GOALS_T$2.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$2
                  WHERE CAREER_GOALS_T$2.PLAN_ID = P.ID AND CAREER_GOALS_T$2.GOAL_ID = 40
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_CLIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$3.ID, 
                     CAREER_GOALS_T$3.GOAL_ID, 
                     CAREER_GOALS_T$3.CREATED_BY, 
                     CAREER_GOALS_T$3.CREATED_DATE, 
                     CAREER_GOALS_T$3.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$3.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$3.PLAN_ID, 
                     CAREER_GOALS_T$3.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$3
                  WHERE CAREER_GOALS_T$3.PLAN_ID = P.ID AND CAREER_GOALS_T$3.GOAL_ID = 41
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_INTLPROP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$4.ID, 
                     CAREER_GOALS_T$4.GOAL_ID, 
                     CAREER_GOALS_T$4.CREATED_BY, 
                     CAREER_GOALS_T$4.CREATED_DATE, 
                     CAREER_GOALS_T$4.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$4.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$4.PLAN_ID, 
                     CAREER_GOALS_T$4.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$4
                  WHERE CAREER_GOALS_T$4.PLAN_ID = P.ID AND CAREER_GOALS_T$4.GOAL_ID = 112
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_RESEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$5.ID, 
                     CAREER_GOALS_T$5.GOAL_ID, 
                     CAREER_GOALS_T$5.CREATED_BY, 
                     CAREER_GOALS_T$5.CREATED_DATE, 
                     CAREER_GOALS_T$5.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$5.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$5.PLAN_ID, 
                     CAREER_GOALS_T$5.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$5
                  WHERE CAREER_GOALS_T$5.PLAN_ID = P.ID AND CAREER_GOALS_T$5.GOAL_ID = 113
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_PROJMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$6.ID, 
                     CAREER_GOALS_T$6.GOAL_ID, 
                     CAREER_GOALS_T$6.CREATED_BY, 
                     CAREER_GOALS_T$6.CREATED_DATE, 
                     CAREER_GOALS_T$6.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$6.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$6.PLAN_ID, 
                     CAREER_GOALS_T$6.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$6
                  WHERE CAREER_GOALS_T$6.PLAN_ID = P.ID AND CAREER_GOALS_T$6.GOAL_ID = 114
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_POLICY_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$7.ID, 
                     CAREER_GOALS_T$7.GOAL_ID, 
                     CAREER_GOALS_T$7.CREATED_BY, 
                     CAREER_GOALS_T$7.CREATED_DATE, 
                     CAREER_GOALS_T$7.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$7.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$7.PLAN_ID, 
                     CAREER_GOALS_T$7.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$7
                  WHERE CAREER_GOALS_T$7.PLAN_ID = P.ID AND CAREER_GOALS_T$7.GOAL_ID = 115
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_TEACHING_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$8.ID, 
                     CAREER_GOALS_T$8.GOAL_ID, 
                     CAREER_GOALS_T$8.CREATED_BY, 
                     CAREER_GOALS_T$8.CREATED_DATE, 
                     CAREER_GOALS_T$8.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$8.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$8.PLAN_ID, 
                     CAREER_GOALS_T$8.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$8
                  WHERE CAREER_GOALS_T$8.PLAN_ID = P.ID AND CAREER_GOALS_T$8.GOAL_ID = 185
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_ACADEMIA_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$9.ID, 
                     CAREER_GOALS_T$9.GOAL_ID, 
                     CAREER_GOALS_T$9.CREATED_BY, 
                     CAREER_GOALS_T$9.CREATED_DATE, 
                     CAREER_GOALS_T$9.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$9.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$9.PLAN_ID, 
                     CAREER_GOALS_T$9.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$9
                  WHERE CAREER_GOALS_T$9.PLAN_ID = P.ID AND CAREER_GOALS_T$9.GOAL_ID = 186
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_ADMIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$10.ID, 
                     CAREER_GOALS_T$10.GOAL_ID, 
                     CAREER_GOALS_T$10.CREATED_BY, 
                     CAREER_GOALS_T$10.CREATED_DATE, 
                     CAREER_GOALS_T$10.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$10.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$10.PLAN_ID, 
                     CAREER_GOALS_T$10.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$10
                  WHERE CAREER_GOALS_T$10.PLAN_ID = P.ID AND CAREER_GOALS_T$10.GOAL_ID = 42
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$11.ID, 
                     CAREER_GOALS_T$11.GOAL_ID, 
                     CAREER_GOALS_T$11.CREATED_BY, 
                     CAREER_GOALS_T$11.CREATED_DATE, 
                     CAREER_GOALS_T$11.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$11.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$11.PLAN_ID, 
                     CAREER_GOALS_T$11.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$11
                  WHERE CAREER_GOALS_T$11.PLAN_ID = P.ID AND CAREER_GOALS_T$11.GOAL_ID = 43
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_CLIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$12.ID, 
                     CAREER_GOALS_T$12.GOAL_ID, 
                     CAREER_GOALS_T$12.CREATED_BY, 
                     CAREER_GOALS_T$12.CREATED_DATE, 
                     CAREER_GOALS_T$12.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$12.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$12.PLAN_ID, 
                     CAREER_GOALS_T$12.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$12
                  WHERE CAREER_GOALS_T$12.PLAN_ID = P.ID AND CAREER_GOALS_T$12.GOAL_ID = 44
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_INTLPROP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$13.ID, 
                     CAREER_GOALS_T$13.GOAL_ID, 
                     CAREER_GOALS_T$13.CREATED_BY, 
                     CAREER_GOALS_T$13.CREATED_DATE, 
                     CAREER_GOALS_T$13.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$13.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$13.PLAN_ID, 
                     CAREER_GOALS_T$13.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$13
                  WHERE CAREER_GOALS_T$13.PLAN_ID = P.ID AND CAREER_GOALS_T$13.GOAL_ID = 116
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_RESEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$14.ID, 
                     CAREER_GOALS_T$14.GOAL_ID, 
                     CAREER_GOALS_T$14.CREATED_BY, 
                     CAREER_GOALS_T$14.CREATED_DATE, 
                     CAREER_GOALS_T$14.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$14.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$14.PLAN_ID, 
                     CAREER_GOALS_T$14.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$14
                  WHERE CAREER_GOALS_T$14.PLAN_ID = P.ID AND CAREER_GOALS_T$14.GOAL_ID = 117
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_PROJMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$15.ID, 
                     CAREER_GOALS_T$15.GOAL_ID, 
                     CAREER_GOALS_T$15.CREATED_BY, 
                     CAREER_GOALS_T$15.CREATED_DATE, 
                     CAREER_GOALS_T$15.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$15.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$15.PLAN_ID, 
                     CAREER_GOALS_T$15.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$15
                  WHERE CAREER_GOALS_T$15.PLAN_ID = P.ID AND CAREER_GOALS_T$15.GOAL_ID = 118
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_POLICY_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$16.ID, 
                     CAREER_GOALS_T$16.GOAL_ID, 
                     CAREER_GOALS_T$16.CREATED_BY, 
                     CAREER_GOALS_T$16.CREATED_DATE, 
                     CAREER_GOALS_T$16.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$16.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$16.PLAN_ID, 
                     CAREER_GOALS_T$16.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$16
                  WHERE CAREER_GOALS_T$16.PLAN_ID = P.ID AND CAREER_GOALS_T$16.GOAL_ID = 119
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_GOVT_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$17.ID, 
                     CAREER_GOALS_T$17.GOAL_ID, 
                     CAREER_GOALS_T$17.CREATED_BY, 
                     CAREER_GOALS_T$17.CREATED_DATE, 
                     CAREER_GOALS_T$17.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$17.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$17.PLAN_ID, 
                     CAREER_GOALS_T$17.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$17
                  WHERE CAREER_GOALS_T$17.PLAN_ID = P.ID AND CAREER_GOALS_T$17.GOAL_ID = 187
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_ADMIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$18.ID, 
                     CAREER_GOALS_T$18.GOAL_ID, 
                     CAREER_GOALS_T$18.CREATED_BY, 
                     CAREER_GOALS_T$18.CREATED_DATE, 
                     CAREER_GOALS_T$18.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$18.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$18.PLAN_ID, 
                     CAREER_GOALS_T$18.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$18
                  WHERE CAREER_GOALS_T$18.PLAN_ID = P.ID AND CAREER_GOALS_T$18.GOAL_ID = 45
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_CONSULT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$19.ID, 
                     CAREER_GOALS_T$19.GOAL_ID, 
                     CAREER_GOALS_T$19.CREATED_BY, 
                     CAREER_GOALS_T$19.CREATED_DATE, 
                     CAREER_GOALS_T$19.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$19.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$19.PLAN_ID, 
                     CAREER_GOALS_T$19.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$19
                  WHERE CAREER_GOALS_T$19.PLAN_ID = P.ID AND CAREER_GOALS_T$19.GOAL_ID = 46
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$20.ID, 
                     CAREER_GOALS_T$20.GOAL_ID, 
                     CAREER_GOALS_T$20.CREATED_BY, 
                     CAREER_GOALS_T$20.CREATED_DATE, 
                     CAREER_GOALS_T$20.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$20.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$20.PLAN_ID, 
                     CAREER_GOALS_T$20.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$20
                  WHERE CAREER_GOALS_T$20.PLAN_ID = P.ID AND CAREER_GOALS_T$20.GOAL_ID = 47
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_CLIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$21.ID, 
                     CAREER_GOALS_T$21.GOAL_ID, 
                     CAREER_GOALS_T$21.CREATED_BY, 
                     CAREER_GOALS_T$21.CREATED_DATE, 
                     CAREER_GOALS_T$21.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$21.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$21.PLAN_ID, 
                     CAREER_GOALS_T$21.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$21
                  WHERE CAREER_GOALS_T$21.PLAN_ID = P.ID AND CAREER_GOALS_T$21.GOAL_ID = 48
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_INTLPROP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$22.ID, 
                     CAREER_GOALS_T$22.GOAL_ID, 
                     CAREER_GOALS_T$22.CREATED_BY, 
                     CAREER_GOALS_T$22.CREATED_DATE, 
                     CAREER_GOALS_T$22.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$22.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$22.PLAN_ID, 
                     CAREER_GOALS_T$22.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$22
                  WHERE CAREER_GOALS_T$22.PLAN_ID = P.ID AND CAREER_GOALS_T$22.GOAL_ID = 120
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_RESEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$23.ID, 
                     CAREER_GOALS_T$23.GOAL_ID, 
                     CAREER_GOALS_T$23.CREATED_BY, 
                     CAREER_GOALS_T$23.CREATED_DATE, 
                     CAREER_GOALS_T$23.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$23.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$23.PLAN_ID, 
                     CAREER_GOALS_T$23.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$23
                  WHERE CAREER_GOALS_T$23.PLAN_ID = P.ID AND CAREER_GOALS_T$23.GOAL_ID = 121
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_PROJMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$24.ID, 
                     CAREER_GOALS_T$24.GOAL_ID, 
                     CAREER_GOALS_T$24.CREATED_BY, 
                     CAREER_GOALS_T$24.CREATED_DATE, 
                     CAREER_GOALS_T$24.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$24.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$24.PLAN_ID, 
                     CAREER_GOALS_T$24.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$24
                  WHERE CAREER_GOALS_T$24.PLAN_ID = P.ID AND CAREER_GOALS_T$24.GOAL_ID = 122
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_POLICY_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$25.ID, 
                     CAREER_GOALS_T$25.GOAL_ID, 
                     CAREER_GOALS_T$25.CREATED_BY, 
                     CAREER_GOALS_T$25.CREATED_DATE, 
                     CAREER_GOALS_T$25.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$25.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$25.PLAN_ID, 
                     CAREER_GOALS_T$25.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$25
                  WHERE CAREER_GOALS_T$25.PLAN_ID = P.ID AND CAREER_GOALS_T$25.GOAL_ID = 124
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_PROFIT_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$26.ID, 
                     CAREER_GOALS_T$26.GOAL_ID, 
                     CAREER_GOALS_T$26.CREATED_BY, 
                     CAREER_GOALS_T$26.CREATED_DATE, 
                     CAREER_GOALS_T$26.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$26.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$26.PLAN_ID, 
                     CAREER_GOALS_T$26.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$26
                  WHERE CAREER_GOALS_T$26.PLAN_ID = P.ID AND CAREER_GOALS_T$26.GOAL_ID = 188
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_ADMIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$27.ID, 
                     CAREER_GOALS_T$27.GOAL_ID, 
                     CAREER_GOALS_T$27.CREATED_BY, 
                     CAREER_GOALS_T$27.CREATED_DATE, 
                     CAREER_GOALS_T$27.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$27.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$27.PLAN_ID, 
                     CAREER_GOALS_T$27.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$27
                  WHERE CAREER_GOALS_T$27.PLAN_ID = P.ID AND CAREER_GOALS_T$27.GOAL_ID = 130
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_CONSULT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$28.ID, 
                     CAREER_GOALS_T$28.GOAL_ID, 
                     CAREER_GOALS_T$28.CREATED_BY, 
                     CAREER_GOALS_T$28.CREATED_DATE, 
                     CAREER_GOALS_T$28.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$28.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$28.PLAN_ID, 
                     CAREER_GOALS_T$28.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$28
                  WHERE CAREER_GOALS_T$28.PLAN_ID = P.ID AND CAREER_GOALS_T$28.GOAL_ID = 131
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$29.ID, 
                     CAREER_GOALS_T$29.GOAL_ID, 
                     CAREER_GOALS_T$29.CREATED_BY, 
                     CAREER_GOALS_T$29.CREATED_DATE, 
                     CAREER_GOALS_T$29.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$29.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$29.PLAN_ID, 
                     CAREER_GOALS_T$29.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$29
                  WHERE CAREER_GOALS_T$29.PLAN_ID = P.ID AND CAREER_GOALS_T$29.GOAL_ID = 132
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_CLIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$30.ID, 
                     CAREER_GOALS_T$30.GOAL_ID, 
                     CAREER_GOALS_T$30.CREATED_BY, 
                     CAREER_GOALS_T$30.CREATED_DATE, 
                     CAREER_GOALS_T$30.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$30.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$30.PLAN_ID, 
                     CAREER_GOALS_T$30.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$30
                  WHERE CAREER_GOALS_T$30.PLAN_ID = P.ID AND CAREER_GOALS_T$30.GOAL_ID = 189
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_INTLPROP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$31.ID, 
                     CAREER_GOALS_T$31.GOAL_ID, 
                     CAREER_GOALS_T$31.CREATED_BY, 
                     CAREER_GOALS_T$31.CREATED_DATE, 
                     CAREER_GOALS_T$31.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$31.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$31.PLAN_ID, 
                     CAREER_GOALS_T$31.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$31
                  WHERE CAREER_GOALS_T$31.PLAN_ID = P.ID AND CAREER_GOALS_T$31.GOAL_ID = 133
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_RESEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$32.ID, 
                     CAREER_GOALS_T$32.GOAL_ID, 
                     CAREER_GOALS_T$32.CREATED_BY, 
                     CAREER_GOALS_T$32.CREATED_DATE, 
                     CAREER_GOALS_T$32.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$32.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$32.PLAN_ID, 
                     CAREER_GOALS_T$32.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$32
                  WHERE CAREER_GOALS_T$32.PLAN_ID = P.ID AND CAREER_GOALS_T$32.GOAL_ID = 136
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_PROJMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$33.ID, 
                     CAREER_GOALS_T$33.GOAL_ID, 
                     CAREER_GOALS_T$33.CREATED_BY, 
                     CAREER_GOALS_T$33.CREATED_DATE, 
                     CAREER_GOALS_T$33.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$33.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$33.PLAN_ID, 
                     CAREER_GOALS_T$33.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$33
                  WHERE CAREER_GOALS_T$33.PLAN_ID = P.ID AND CAREER_GOALS_T$33.GOAL_ID = 134
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_POLICY_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$34.ID, 
                     CAREER_GOALS_T$34.GOAL_ID, 
                     CAREER_GOALS_T$34.CREATED_BY, 
                     CAREER_GOALS_T$34.CREATED_DATE, 
                     CAREER_GOALS_T$34.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$34.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$34.PLAN_ID, 
                     CAREER_GOALS_T$34.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$34
                  WHERE CAREER_GOALS_T$34.PLAN_ID = P.ID AND CAREER_GOALS_T$34.GOAL_ID = 135
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_NONPROFIT_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$35.ID, 
                     CAREER_GOALS_T$35.GOAL_ID, 
                     CAREER_GOALS_T$35.CREATED_BY, 
                     CAREER_GOALS_T$35.CREATED_DATE, 
                     CAREER_GOALS_T$35.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$35.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$35.PLAN_ID, 
                     CAREER_GOALS_T$35.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$35
                  WHERE CAREER_GOALS_T$35.PLAN_ID = P.ID AND CAREER_GOALS_T$35.GOAL_ID = 137
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_ADMIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$36.ID, 
                     CAREER_GOALS_T$36.GOAL_ID, 
                     CAREER_GOALS_T$36.CREATED_BY, 
                     CAREER_GOALS_T$36.CREATED_DATE, 
                     CAREER_GOALS_T$36.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$36.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$36.PLAN_ID, 
                     CAREER_GOALS_T$36.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$36
                  WHERE CAREER_GOALS_T$36.PLAN_ID = P.ID AND CAREER_GOALS_T$36.GOAL_ID = 49
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_CONSULT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$37.ID, 
                     CAREER_GOALS_T$37.GOAL_ID, 
                     CAREER_GOALS_T$37.CREATED_BY, 
                     CAREER_GOALS_T$37.CREATED_DATE, 
                     CAREER_GOALS_T$37.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$37.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$37.PLAN_ID, 
                     CAREER_GOALS_T$37.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$37
                  WHERE CAREER_GOALS_T$37.PLAN_ID = P.ID AND CAREER_GOALS_T$37.GOAL_ID = 51
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$38.ID, 
                     CAREER_GOALS_T$38.GOAL_ID, 
                     CAREER_GOALS_T$38.CREATED_BY, 
                     CAREER_GOALS_T$38.CREATED_DATE, 
                     CAREER_GOALS_T$38.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$38.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$38.PLAN_ID, 
                     CAREER_GOALS_T$38.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$38
                  WHERE CAREER_GOALS_T$38.PLAN_ID = P.ID AND CAREER_GOALS_T$38.GOAL_ID = 50
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_CLIN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$39.ID, 
                     CAREER_GOALS_T$39.GOAL_ID, 
                     CAREER_GOALS_T$39.CREATED_BY, 
                     CAREER_GOALS_T$39.CREATED_DATE, 
                     CAREER_GOALS_T$39.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$39.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$39.PLAN_ID, 
                     CAREER_GOALS_T$39.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$39
                  WHERE CAREER_GOALS_T$39.PLAN_ID = P.ID AND CAREER_GOALS_T$39.GOAL_ID = 190
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_INTLPROP_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$40.ID, 
                     CAREER_GOALS_T$40.GOAL_ID, 
                     CAREER_GOALS_T$40.CREATED_BY, 
                     CAREER_GOALS_T$40.CREATED_DATE, 
                     CAREER_GOALS_T$40.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$40.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$40.PLAN_ID, 
                     CAREER_GOALS_T$40.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$40
                  WHERE CAREER_GOALS_T$40.PLAN_ID = P.ID AND CAREER_GOALS_T$40.GOAL_ID = 125
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_RESEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$41.ID, 
                     CAREER_GOALS_T$41.GOAL_ID, 
                     CAREER_GOALS_T$41.CREATED_BY, 
                     CAREER_GOALS_T$41.CREATED_DATE, 
                     CAREER_GOALS_T$41.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$41.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$41.PLAN_ID, 
                     CAREER_GOALS_T$41.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$41
                  WHERE CAREER_GOALS_T$41.PLAN_ID = P.ID AND CAREER_GOALS_T$41.GOAL_ID = 128
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_PROJMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$42.ID, 
                     CAREER_GOALS_T$42.GOAL_ID, 
                     CAREER_GOALS_T$42.CREATED_BY, 
                     CAREER_GOALS_T$42.CREATED_DATE, 
                     CAREER_GOALS_T$42.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$42.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$42.PLAN_ID, 
                     CAREER_GOALS_T$42.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$42
                  WHERE CAREER_GOALS_T$42.PLAN_ID = P.ID AND CAREER_GOALS_T$42.GOAL_ID = 126
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_POLICY_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$43.ID, 
                     CAREER_GOALS_T$43.GOAL_ID, 
                     CAREER_GOALS_T$43.CREATED_BY, 
                     CAREER_GOALS_T$43.CREATED_DATE, 
                     CAREER_GOALS_T$43.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$43.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$43.PLAN_ID, 
                     CAREER_GOALS_T$43.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$43
                  WHERE CAREER_GOALS_T$43.PLAN_ID = P.ID AND CAREER_GOALS_T$43.GOAL_ID = 127
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_TEACHING_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$44.ID, 
                     CAREER_GOALS_T$44.GOAL_ID, 
                     CAREER_GOALS_T$44.CREATED_BY, 
                     CAREER_GOALS_T$44.CREATED_DATE, 
                     CAREER_GOALS_T$44.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$44.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$44.PLAN_ID, 
                     CAREER_GOALS_T$44.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$44
                  WHERE CAREER_GOALS_T$44.PLAN_ID = P.ID AND CAREER_GOALS_T$44.GOAL_ID = 191
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* GOAL_OTHER_OTHER_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_GOALS_T$45.ID, 
                     CAREER_GOALS_T$45.GOAL_ID, 
                     CAREER_GOALS_T$45.CREATED_BY, 
                     CAREER_GOALS_T$45.CREATED_DATE, 
                     CAREER_GOALS_T$45.LAST_CHANGED_BY, 
                     CAREER_GOALS_T$45.LAST_CHANGED_DATE, 
                     CAREER_GOALS_T$45.PLAN_ID, 
                     CAREER_GOALS_T$45.OTHER_TEXT
                  FROM IDP.CAREER_GOALS_T  AS CAREER_GOALS_T$45
                  WHERE CAREER_GOALS_T$45.PLAN_ID = P.ID AND CAREER_GOALS_T$45.GOAL_ID = 129
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_CAREEREXPNTWK_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T.ID, 
                     CAREER_EXPLORATION_T.PLAN_ID, 
                     CAREER_EXPLORATION_T.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T.DESCRIPTION, 
                     CAREER_EXPLORATION_T.TITLE_ID, 
                     CAREER_EXPLORATION_T.CREATED_BY, 
                     CAREER_EXPLORATION_T.CREATED_DATE, 
                     CAREER_EXPLORATION_T.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T.STATUS_ID, 
                     CAREER_EXPLORATION_T.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T
                  WHERE CAREER_EXPLORATION_T.PLAN_ID = P.ID AND CAREER_EXPLORATION_T.EXPLORATION_ID = 29
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_COMM_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$2.ID, 
                     CAREER_EXPLORATION_T$2.PLAN_ID, 
                     CAREER_EXPLORATION_T$2.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$2.DESCRIPTION, 
                     CAREER_EXPLORATION_T$2.TITLE_ID, 
                     CAREER_EXPLORATION_T$2.CREATED_BY, 
                     CAREER_EXPLORATION_T$2.CREATED_DATE, 
                     CAREER_EXPLORATION_T$2.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$2.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$2.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$2.STATUS_ID, 
                     CAREER_EXPLORATION_T$2.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$2.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$2.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$2
                  WHERE CAREER_EXPLORATION_T$2.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$2.EXPLORATION_ID = 30
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_ETHICS_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$3.ID, 
                     CAREER_EXPLORATION_T$3.PLAN_ID, 
                     CAREER_EXPLORATION_T$3.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$3.DESCRIPTION, 
                     CAREER_EXPLORATION_T$3.TITLE_ID, 
                     CAREER_EXPLORATION_T$3.CREATED_BY, 
                     CAREER_EXPLORATION_T$3.CREATED_DATE, 
                     CAREER_EXPLORATION_T$3.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$3.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$3.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$3.STATUS_ID, 
                     CAREER_EXPLORATION_T$3.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$3.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$3.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$3
                  WHERE CAREER_EXPLORATION_T$3.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$3.EXPLORATION_ID = 58
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_GRANTWR_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$4.ID, 
                     CAREER_EXPLORATION_T$4.PLAN_ID, 
                     CAREER_EXPLORATION_T$4.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$4.DESCRIPTION, 
                     CAREER_EXPLORATION_T$4.TITLE_ID, 
                     CAREER_EXPLORATION_T$4.CREATED_BY, 
                     CAREER_EXPLORATION_T$4.CREATED_DATE, 
                     CAREER_EXPLORATION_T$4.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$4.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$4.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$4.STATUS_ID, 
                     CAREER_EXPLORATION_T$4.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$4.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$4.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$4
                  WHERE CAREER_EXPLORATION_T$4.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$4.EXPLORATION_ID = 32
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_LEADMGMT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$5.ID, 
                     CAREER_EXPLORATION_T$5.PLAN_ID, 
                     CAREER_EXPLORATION_T$5.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$5.DESCRIPTION, 
                     CAREER_EXPLORATION_T$5.TITLE_ID, 
                     CAREER_EXPLORATION_T$5.CREATED_BY, 
                     CAREER_EXPLORATION_T$5.CREATED_DATE, 
                     CAREER_EXPLORATION_T$5.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$5.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$5.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$5.STATUS_ID, 
                     CAREER_EXPLORATION_T$5.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$5.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$5.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$5
                  WHERE CAREER_EXPLORATION_T$5.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$5.EXPLORATION_ID = 31
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_MANDTRN_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$6.ID, 
                     CAREER_EXPLORATION_T$6.PLAN_ID, 
                     CAREER_EXPLORATION_T$6.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$6.DESCRIPTION, 
                     CAREER_EXPLORATION_T$6.TITLE_ID, 
                     CAREER_EXPLORATION_T$6.CREATED_BY, 
                     CAREER_EXPLORATION_T$6.CREATED_DATE, 
                     CAREER_EXPLORATION_T$6.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$6.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$6.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$6.STATUS_ID, 
                     CAREER_EXPLORATION_T$6.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$6.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$6.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$6
                  WHERE CAREER_EXPLORATION_T$6.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$6.EXPLORATION_ID = 330
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_MENTOR_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$7.ID, 
                     CAREER_EXPLORATION_T$7.PLAN_ID, 
                     CAREER_EXPLORATION_T$7.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$7.DESCRIPTION, 
                     CAREER_EXPLORATION_T$7.TITLE_ID, 
                     CAREER_EXPLORATION_T$7.CREATED_BY, 
                     CAREER_EXPLORATION_T$7.CREATED_DATE, 
                     CAREER_EXPLORATION_T$7.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$7.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$7.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$7.STATUS_ID, 
                     CAREER_EXPLORATION_T$7.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$7.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$7.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$7
                  WHERE CAREER_EXPLORATION_T$7.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$7.EXPLORATION_ID = 33
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_SCMNSCRPT_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$8.ID, 
                     CAREER_EXPLORATION_T$8.PLAN_ID, 
                     CAREER_EXPLORATION_T$8.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$8.DESCRIPTION, 
                     CAREER_EXPLORATION_T$8.TITLE_ID, 
                     CAREER_EXPLORATION_T$8.CREATED_BY, 
                     CAREER_EXPLORATION_T$8.CREATED_DATE, 
                     CAREER_EXPLORATION_T$8.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$8.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$8.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$8.STATUS_ID, 
                     CAREER_EXPLORATION_T$8.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$8.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$8.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$8
                  WHERE CAREER_EXPLORATION_T$8.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$8.EXPLORATION_ID = 53
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_SK_OTHERS_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$9.ID, 
                     CAREER_EXPLORATION_T$9.PLAN_ID, 
                     CAREER_EXPLORATION_T$9.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$9.DESCRIPTION, 
                     CAREER_EXPLORATION_T$9.TITLE_ID, 
                     CAREER_EXPLORATION_T$9.CREATED_BY, 
                     CAREER_EXPLORATION_T$9.CREATED_DATE, 
                     CAREER_EXPLORATION_T$9.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$9.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$9.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$9.STATUS_ID, 
                     CAREER_EXPLORATION_T$9.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$9.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$9.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$9
                  WHERE CAREER_EXPLORATION_T$9.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$9.EXPLORATION_ID = 54
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_JOBSEARCH_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$10.ID, 
                     CAREER_EXPLORATION_T$10.PLAN_ID, 
                     CAREER_EXPLORATION_T$10.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$10.DESCRIPTION, 
                     CAREER_EXPLORATION_T$10.TITLE_ID, 
                     CAREER_EXPLORATION_T$10.CREATED_BY, 
                     CAREER_EXPLORATION_T$10.CREATED_DATE, 
                     CAREER_EXPLORATION_T$10.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$10.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$10.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$10.STATUS_ID, 
                     CAREER_EXPLORATION_T$10.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$10.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$10.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$10
                  WHERE CAREER_EXPLORATION_T$10.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$10.EXPLORATION_ID = 55
               ) THEN 'Y'
            ELSE 'N'
         END
      END, 
      /* CAREEREXPTR_OTHERS_FLAG*/CASE 
         WHEN P.ID IS NULL THEN NULL
         ELSE CASE 
            WHEN EXISTS 
               (
                  SELECT 
                     CAREER_EXPLORATION_T$11.ID, 
                     CAREER_EXPLORATION_T$11.PLAN_ID, 
                     CAREER_EXPLORATION_T$11.EXPLORATION_ID, 
                     CAREER_EXPLORATION_T$11.DESCRIPTION, 
                     CAREER_EXPLORATION_T$11.TITLE_ID, 
                     CAREER_EXPLORATION_T$11.CREATED_BY, 
                     CAREER_EXPLORATION_T$11.CREATED_DATE, 
                     CAREER_EXPLORATION_T$11.LAST_CHANGED_BY, 
                     CAREER_EXPLORATION_T$11.LAST_CHANGED_DATE, 
                     CAREER_EXPLORATION_T$11.PARENT_EXP_ID, 
                     CAREER_EXPLORATION_T$11.STATUS_ID, 
                     CAREER_EXPLORATION_T$11.PROGRESS_UPDATE, 
                     CAREER_EXPLORATION_T$11.IS_EDITABLE_STATUS, 
                     CAREER_EXPLORATION_T$11.EXP_LAST_CHANGED_DATE
                  FROM IDP.CAREER_EXPLORATION_T  AS CAREER_EXPLORATION_T$11
                  WHERE CAREER_EXPLORATION_T$11.PLAN_ID = P.ID AND CAREER_EXPLORATION_T$11.EXPLORATION_ID = 56
               ) THEN 'Y'
            ELSE 'N'
         END
      END
   FROM 
      IDP.NVISION_TRAINEES_T  AS NV 
         LEFT OUTER JOIN IDP.PLANS_T  AS P 
         ON NV.NED_ID = P.TRAINEE_NED_ID 
         LEFT OUTER JOIN IDP.LOOKUP_T  AS IDP_LOOK 
         ON P.IDP_TYPE_ID = IDP_LOOK.ID
   WHERE ((P.ID IS NULL AND NV.ORGANIZATIONALSTAT IN ( 'EMPLOYEE', 'FELLOW' )) OR P.ID IS NOT NULL)
GO
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------







