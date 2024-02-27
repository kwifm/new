/****** Object:  UserDefinedFunction [dbo].[db_error_get_oracle_exception_id]  FOR SP [GRIST].[GETLIBCOMPARE_NEW] and [IDP].[NVISION_SYNC] Script Date: 2/23/2024 11:15:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[db_error_get_oracle_exception_id]
 (
  @message nvarchar(4000),
  @number int
 )
 returns nvarchar(4000)
as
begin
 if(@number = 2627)
  return N'ORA-00001'
 if(@number = 8134)
  return N'ORA-01476'
 if(@number = 16915)
  return N'ORA-06511'
 if(@number = 16917)
  return N'ORA-01001'
 if(@number = 512)
  return N'ORA-01422'
    if(@number = 547)
  return N'ORA-02291'
 if(@number = 59999)
 begin
  declare @start int
  set @start = CHARINDEX(N'[', @message)
  if(@start > 0)
  begin
   declare @end int
   set @end = CHARINDEX(N']', @message, @start)
   if(@end > 0)
   begin
    return SUBSTRING(@message, @start + 1, @end - @start - 1)
   end
  end
  return null
 end
 if (@number = 59998)
  return @message
 return null
end
GO
----------------------------------------------------------------------
----------------------------------------------------------------------
/****** Object:  UserDefinedFunction [ssma_oracle].[trunc_date]  FOR SP [IDP].[NVISION_SYNC]  Script Date: 2/25/2024 10:13:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[trunc_date](@date_t as datetime)
returns datetime
begin
    return dateadd(hh, -datepart(hh, @date_t), 
                dateadd(mi, -datepart(mi, @date_t), 
                    dateadd(ss, -datepart(ss, @date_t), 
                    dateadd(ms, -datepart(ms, @date_t), @date_t))));
end
GO

------------------------------------------------------------------
------------------------------------------------------------------
/****** Object:  StoredProcedure [ssma_oracle].[ssma_rethrowerror]  FOR SP [IDP].[NVISION_SYNC]  Script Date: 2/25/2024 10:19:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[rethrowerror] AS
    
    IF ERROR_NUMBER() IS NULL
        RETURN;

    DECLARE 
        @errormessage    NVARCHAR(4000),
        @errornumber     INT,
        @errorseverity   INT,
        @errorstate      INT,
        @errorline       INT,
        @errorprocedure  NVARCHAR(200);

    SELECT 
        @errornumber = ERROR_NUMBER(),
        @errorseverity = ERROR_SEVERITY(),
        @errorstate = ERROR_STATE(),
        @errorline = ERROR_LINE(),
        @errorprocedure = ISNULL(ERROR_PROCEDURE(), '-');

    SELECT @errormessage = 
        N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
            'Message: '+ ERROR_MESSAGE();

    RAISERROR 
        (
        @errormessage, 
        @errorseverity, 
        1,               
        @errornumber,    
        @errorseverity,  
        @errorstate,     
        @errorprocedure, 
        @errorline       
        );
GO

------------------------------------------------------------------
------------------------------------------------------------------


