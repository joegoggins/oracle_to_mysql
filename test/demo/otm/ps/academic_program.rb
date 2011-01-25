module Otm
  module Ps
    class AcademicProgram
      
      include OracleToMysql

      def otm_target_table
        "test_academic_programs"
      end

      def otm_source_sql
        "select
          trim(INSTITUTION)               || CHR(9) ||
          trim(ACAD_CAREER)               || CHR(9) ||
          trim(STRM)              || CHR(9) ||
          trim(DESCR)             || CHR(9) ||
          trim(DESCRSHORT)                || CHR(9) ||
          case when TERM_BEGIN_DT is null then '\\N' else to_char(TERM_BEGIN_DT, 'YYYY-MM-DD') end || CHR(9) ||
          case when TERM_END_DT is null then '\\N' else to_char(TERM_END_DT, 'YYYY-MM-DD') end     || CHR(9) ||
          trim(SESSION_CODE)              || CHR(9) ||
          WEEKS_OF_INSTRUCT               || CHR(9) ||
          trim(TERM_CATEGORY)             || CHR(9) ||
          trim(ACAD_YEAR)         || CHR(9) ||
          trim(TRANSCIPT_DT_PRT)          || CHR(9) ||
          trim(HOLIDAY_SCHEDULE)          || CHR(9) ||
          case when SIXTY_PCT_DT is null then '\\N' else to_char(SIXTY_PCT_DT, 'YYYY-MM-DD') end   || CHR(9) ||
          trim(USE_DYN_CLASS_DATE)                || CHR(9) ||
          trim(INCLUDE_IN_SS)             || CHR(9) ||
          case when SSR_TRMAC_LAST_DT is null then '\\N' else to_char(SSR_TRMAC_LAST_DT, 'YYYY-MM-DD') end          || CHR(9) ||
          case when SSR_PLNDISPONLY_DT is null then '\\N' else to_char(SSR_PLNDISPONLY_DT, 'YYYY-MM-DD') end                || CHR(9) ||
          case when SSR_SSENRLAVAIL_DT is null then '\\N' else to_char(SSR_SSENRLAVAIL_DT, 'YYYY-MM-DD') end                || CHR(9)
        from ps_term_tbl
        where institution='UMNTC';"
      end
      def otm_target_sql
        "
        create table if not exists #{self.otm_target_table} (
          institution                       varchar(5),
          acad_career                       varchar(4),
          strm                      varchar(4),
          descr                     varchar(30),
          descrshort                        varchar(10),
          term_begin_dt                     date,
          term_end_dt                       date,
          session_code                      varchar(3),
          weeks_of_instruct                 integer,
          term_category                     varchar(1),
          acad_year                 varchar(4),
          transcipt_dt_prt                  varchar(2),
          holiday_schedule                  varchar(6),
          sixty_pct_dt                      date,
          use_dyn_class_date                        varchar(1),
          include_in_ss                     varchar(1),
          ssr_trmac_last_dt                 date,
          ssr_plndisponly_dt                        date,
          ssr_ssenrlavail_dt                        date,
          primary key (institution, acad_career, strm),
          key (institution),
          key (acad_career),
          key (strm),
          key (term_begin_dt),
          key (term_end_dt)
        )
        "
      end
      
      
      
    end
  end
end
