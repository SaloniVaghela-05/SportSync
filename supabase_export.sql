--
-- PostgreSQL database dump
--

\restrict p98kG4dsyjuegM8TQR4aTcFP9QljBjIMnnN9yokrAyRSRK02Q5G7XNsLMCbfOb5

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_player_current_team_info(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_current_team_info(p_player_id character varying) RETURNS TABLE(team_name character varying, college_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        T.team_name,
        T.college_id AS college_name
    FROM
        PlayerTeam PT
    INNER JOIN
        Team T ON PT.team_id = T.team_id
    WHERE
        PT.player_id = p_player_id
        AND (PT.end_date IS NULL OR PT.end_date > CURRENT_DATE)
        AND PT.joining_date <= CURRENT_DATE
    ORDER BY PT.joining_date DESC
    LIMIT 1;
    
    -- If no rows found, RETURN QUERY automatically returns empty result set
    -- No additional RETURN statements needed
END;
$$;


ALTER FUNCTION public.get_player_current_team_info(p_player_id character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accommodation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accommodation (
    person_id character varying(10) NOT NULL,
    tournament_id character varying(10) NOT NULL,
    room_no character varying(10) NOT NULL,
    check_in_date date NOT NULL,
    check_out_date date NOT NULL,
    status character varying(20) NOT NULL,
    CONSTRAINT accommodation_check CHECK ((check_out_date >= check_in_date)),
    CONSTRAINT accommodation_check_in_date_check CHECK ((check_in_date >= '2000-01-01'::date)),
    CONSTRAINT accommodation_status_check CHECK ((lower((status)::text) = ANY (ARRAY['booked'::text, 'checked_in'::text, 'checked_out'::text, 'cancelled'::text])))
);


ALTER TABLE public.accommodation OWNER TO postgres;

--
-- Name: coach; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coach (
    coach_id character varying(10) NOT NULL,
    coach_name character varying(100) NOT NULL,
    contact_no character varying(10) NOT NULL,
    CONSTRAINT coach_contact_no_check CHECK (((contact_no)::text ~ '^[0-9]{10}$'::text))
);


ALTER TABLE public.coach OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    company character varying(100) NOT NULL,
    address character varying(255) NOT NULL
);


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: equipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipments (
    equipment_id character varying(10) NOT NULL,
    equipment_name character varying(100) NOT NULL,
    number integer NOT NULL,
    CONSTRAINT chk_number_nonnegative CHECK ((number >= 0))
);


ALTER TABLE public.equipments OWNER TO postgres;

--
-- Name: match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match (
    match_id character varying(10) NOT NULL,
    sport_id character varying(10) NOT NULL,
    tournament_id character varying(10) NOT NULL,
    date date NOT NULL,
    match_type character varying(20) NOT NULL,
    "time" time without time zone NOT NULL,
    venue_id character varying(10),
    referee_id character varying(10),
    CONSTRAINT match_date_check CHECK (((date >= '2000-01-01'::date) AND (date <= (CURRENT_DATE + '1 year'::interval)))),
    CONSTRAINT match_match_type_check CHECK ((lower((match_type)::text) = ANY (ARRAY['group'::text, 'quarterfinal'::text, 'semifinal'::text, 'final'::text])))
);


ALTER TABLE public.match OWNER TO postgres;

--
-- Name: organizer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizer (
    member_id character varying(10) NOT NULL,
    member_name character varying(100) NOT NULL,
    contact_no character varying(10) NOT NULL,
    CONSTRAINT organizer_contact_no_check CHECK (((contact_no)::text ~ '^[0-9]{10}$'::text))
);


ALTER TABLE public.organizer OWNER TO postgres;

--
-- Name: organizetournament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizetournament (
    tournament_id character varying(10) NOT NULL,
    member_id character varying(10) NOT NULL,
    role character varying(30) NOT NULL,
    department character varying(50) NOT NULL,
    CONSTRAINT organizetournament_department_check CHECK ((lower((department)::text) = ANY (ARRAY['logistics'::text, 'operations'::text, 'marketing'::text, 'finance'::text, 'refereeing'::text, 'medical'::text, 'hospitality'::text, 'technical'::text, 'volunteers'::text]))),
    CONSTRAINT organizetournament_role_check CHECK ((lower((role)::text) = ANY (ARRAY['coordinator'::text, 'manager'::text, 'assistant'::text, 'volunteer'::text])))
);


ALTER TABLE public.organizetournament OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id character varying(10) NOT NULL,
    person_name character varying(100) NOT NULL,
    gender character varying(10),
    dob date NOT NULL,
    contact_no character varying(10) NOT NULL,
    college_name character varying(100),
    roles character varying(50),
    CONSTRAINT person_gender_check CHECK ((lower((gender)::text) = ANY (ARRAY['male'::text, 'female'::text, 'other'::text])))
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player (
    player_id character varying(10) NOT NULL,
    height numeric(5,2) NOT NULL,
    weight numeric(5,2) NOT NULL,
    bloodgroup character varying(5),
    joining_year integer NOT NULL,
    CONSTRAINT player_bloodgroup_check CHECK (((bloodgroup)::text = ANY ((ARRAY['A+'::character varying, 'A-'::character varying, 'B+'::character varying, 'B-'::character varying, 'O+'::character varying, 'O-'::character varying, 'AB+'::character varying, 'AB-'::character varying])::text[]))),
    CONSTRAINT player_height_check CHECK ((height >= (0)::numeric)),
    CONSTRAINT player_joining_year_check CHECK (((joining_year >= 2000) AND (joining_year <= 2035))),
    CONSTRAINT player_weight_check CHECK ((weight >= (0)::numeric))
);


ALTER TABLE public.player OWNER TO postgres;

--
-- Name: playerplaysmatch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playerplaysmatch (
    player_id character varying(10) NOT NULL,
    match_id character varying(10) NOT NULL
);


ALTER TABLE public.playerplaysmatch OWNER TO postgres;

--
-- Name: playersport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playersport (
    player_id character varying(10) NOT NULL,
    sport_id character varying(10) NOT NULL,
    level character varying(20) NOT NULL,
    experience_years integer NOT NULL,
    CONSTRAINT playersport_experience_years_check CHECK ((experience_years >= 0)),
    CONSTRAINT playersport_level_check CHECK ((lower((level)::text) = ANY (ARRAY['beginner'::text, 'intermediate'::text, 'advanced'::text, 'professional'::text])))
);


ALTER TABLE public.playersport OWNER TO postgres;

--
-- Name: playerstatistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playerstatistics (
    player_id character varying(10) NOT NULL,
    match_id character varying(10) NOT NULL,
    status_name character varying(20) NOT NULL,
    score integer NOT NULL,
    CONSTRAINT playerstatistics_score_check CHECK ((score >= 0))
);


ALTER TABLE public.playerstatistics OWNER TO postgres;

--
-- Name: playerteam; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playerteam (
    player_id character varying(10) NOT NULL,
    team_id character varying(10) NOT NULL,
    joining_date date NOT NULL,
    end_date date,
    CONSTRAINT playerteam_check CHECK (((end_date IS NULL) OR (end_date >= joining_date))),
    CONSTRAINT playerteam_joining_date_check CHECK ((joining_date >= '2000-01-01'::date))
);


ALTER TABLE public.playerteam OWNER TO postgres;

--
-- Name: referee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referee (
    referee_id character varying(10) NOT NULL,
    referee_name character varying(100) NOT NULL,
    contact_no character varying(10) NOT NULL,
    CONSTRAINT referee_contact_no_check CHECK (((contact_no)::text ~ '^[0-9]{10}$'::text))
);


ALTER TABLE public.referee OWNER TO postgres;

--
-- Name: result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.result (
    match_id character varying(10) NOT NULL,
    team_id character varying(10) NOT NULL,
    outcome character varying(10) NOT NULL,
    CONSTRAINT result_outcome_check CHECK ((lower((outcome)::text) = ANY (ARRAY['win'::text, 'loss'::text, 'draw'::text])))
);


ALTER TABLE public.result OWNER TO postgres;

--
-- Name: spectatorpass; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spectatorpass (
    spectator_id character varying(10) NOT NULL,
    tournament_id character varying(10) NOT NULL,
    pass_type character varying(10) NOT NULL,
    CONSTRAINT spectatorpass_pass_type_check CHECK ((lower((pass_type)::text) = ANY (ARRAY['gold'::text, 'silver'::text, 'regular'::text])))
);


ALTER TABLE public.spectatorpass OWNER TO postgres;

--
-- Name: spectatorviewmatch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spectatorviewmatch (
    spectator_id character varying(10) NOT NULL,
    match_id character varying(10) NOT NULL
);


ALTER TABLE public.spectatorviewmatch OWNER TO postgres;

--
-- Name: sponsors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsors (
    sponsor_id character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    contact_no character varying(10) NOT NULL,
    company character varying(100) NOT NULL,
    CONSTRAINT chk_contact_no_digits CHECK (((contact_no)::text ~ '^[0-9]{10}$'::text))
);


ALTER TABLE public.sponsors OWNER TO postgres;

--
-- Name: sponsorstournament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsorstournament (
    tournament_id character varying(10) NOT NULL,
    sponsor_id character varying(10) NOT NULL,
    budget numeric(12,2) NOT NULL,
    CONSTRAINT sponsorstournament_budget_check CHECK ((budget >= (0)::numeric))
);


ALTER TABLE public.sponsorstournament OWNER TO postgres;

--
-- Name: sportequipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sportequipments (
    sport_id character varying(10) NOT NULL,
    equipment_id character varying(10) NOT NULL,
    number integer NOT NULL,
    CONSTRAINT sportequipments_number_check CHECK ((number >= 0))
);


ALTER TABLE public.sportequipments OWNER TO postgres;

--
-- Name: sportrules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sportrules (
    sport_id character varying(10) NOT NULL,
    rules text
);


ALTER TABLE public.sportrules OWNER TO postgres;

--
-- Name: sports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sports (
    sport_id character varying(10) NOT NULL,
    sport_name character varying(100) NOT NULL
);


ALTER TABLE public.sports OWNER TO postgres;

--
-- Name: sporttype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sporttype (
    sport_name character varying(100) NOT NULL,
    type character varying(50) NOT NULL
);


ALTER TABLE public.sporttype OWNER TO postgres;

--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    team_id character varying(10) NOT NULL,
    sport_id character varying(10) NOT NULL,
    team_name character varying(100) NOT NULL,
    college_id character varying(100),
    captain_id character varying(10)
);


ALTER TABLE public.team OWNER TO postgres;

--
-- Name: teamcoach; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teamcoach (
    team_id character varying(10) NOT NULL,
    coach_id character varying(10) NOT NULL,
    join_date date NOT NULL,
    end_date date,
    CONSTRAINT teamcoach_check CHECK (((end_date IS NULL) OR (end_date >= join_date))),
    CONSTRAINT teamcoach_join_date_check CHECK ((join_date >= '2000-01-01'::date))
);


ALTER TABLE public.teamcoach OWNER TO postgres;

--
-- Name: teamplaysmatch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teamplaysmatch (
    match_id character varying(10) NOT NULL,
    team_id character varying(10) NOT NULL
);


ALTER TABLE public.teamplaysmatch OWNER TO postgres;

--
-- Name: teamstatistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teamstatistics (
    team_id character varying(10) NOT NULL,
    match_id character varying(10) NOT NULL,
    status_name character varying(20) NOT NULL,
    score integer NOT NULL,
    CONSTRAINT teamstatistics_score_check CHECK ((score >= 0))
);


ALTER TABLE public.teamstatistics OWNER TO postgres;

--
-- Name: tournament; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament (
    tournament_id character varying(10) NOT NULL,
    tournament_year integer NOT NULL,
    season character varying(20),
    start_date date NOT NULL,
    end_date date NOT NULL,
    CONSTRAINT chk_dates CHECK ((end_date >= start_date)),
    CONSTRAINT tournament_season_check CHECK ((lower((season)::text) = ANY (ARRAY['fall'::text, 'spring'::text]))),
    CONSTRAINT tournament_tournament_year_check CHECK (((tournament_year >= 2000) AND (tournament_year <= 2035)))
);


ALTER TABLE public.tournament OWNER TO postgres;

--
-- Name: venue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venue (
    venue_id character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    location character varying(255)
);


ALTER TABLE public.venue OWNER TO postgres;

--
-- Data for Name: accommodation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.accommodation VALUES ('P001', 'T001', 'H101', '2019-03-09', '2019-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P005', 'T001', 'H102', '2019-03-09', '2019-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P011', 'T001', 'H103', '2019-03-10', '2019-03-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P020', 'T001', 'H104', '2019-03-08', '2019-03-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P027', 'T001', 'H105', '2019-03-11', '2019-03-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P205', 'T001', 'G201', '2019-03-10', '2019-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P211', 'T001', 'G202', '2019-03-12', '2019-03-14', 'cancelled');
INSERT INTO public.accommodation VALUES ('P259', 'T001', 'G203', '2019-03-09', '2019-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P002', 'T002', 'H110', '2019-09-14', '2019-09-26', 'checked_out');
INSERT INTO public.accommodation VALUES ('P007', 'T002', 'H111', '2019-09-15', '2019-09-25', 'checked_out');
INSERT INTO public.accommodation VALUES ('P015', 'T002', 'H112', '2019-09-13', '2019-09-27', 'checked_out');
INSERT INTO public.accommodation VALUES ('P023', 'T002', 'H113', '2019-09-16', '2019-09-24', 'checked_out');
INSERT INTO public.accommodation VALUES ('P031', 'T002', 'H114', '2019-09-17', '2019-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P202', 'T002', 'G210', '2019-09-15', '2019-09-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P239', 'T002', 'G211', '2019-09-16', '2019-09-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P247', 'T002', 'G212', '2019-09-14', '2019-09-26', 'checked_out');
INSERT INTO public.accommodation VALUES ('P004', 'T003', 'H120', '2020-03-10', '2020-03-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P009', 'T003', 'H121', '2020-03-11', '2020-03-23', 'checked_out');
INSERT INTO public.accommodation VALUES ('P017', 'T003', 'H122', '2020-03-13', '2020-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P029', 'T003', 'H123', '2020-03-12', '2020-03-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P035', 'T003', 'H124', '2020-03-14', '2020-03-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P203', 'T003', 'G220', '2020-03-12', '2020-03-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P212', 'T003', 'G221', '2020-03-11', '2020-03-23', 'checked_out');
INSERT INTO public.accommodation VALUES ('P257', 'T003', 'G222', '2020-03-13', '2020-03-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P006', 'T004', 'H130', '2020-09-17', '2020-09-29', 'checked_out');
INSERT INTO public.accommodation VALUES ('P013', 'T004', 'H131', '2020-09-18', '2020-09-26', 'checked_out');
INSERT INTO public.accommodation VALUES ('P021', 'T004', 'H132', '2020-09-19', '2020-09-27', 'checked_out');
INSERT INTO public.accommodation VALUES ('P030', 'T004', 'H133', '2020-09-16', '2020-09-28', 'checked_out');
INSERT INTO public.accommodation VALUES ('P039', 'T004', 'H134', '2020-09-20', '2020-09-25', 'checked_out');
INSERT INTO public.accommodation VALUES ('P213', 'T004', 'G230', '2020-09-19', '2020-09-24', 'checked_out');
INSERT INTO public.accommodation VALUES ('P216', 'T004', 'G231', '2020-09-17', '2020-09-29', 'checked_out');
INSERT INTO public.accommodation VALUES ('P245', 'T004', 'G232', '2020-09-21', '2020-09-28', 'checked_out');
INSERT INTO public.accommodation VALUES ('P003', 'T005', 'H140', '2021-03-07', '2021-03-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P008', 'T005', 'H141', '2021-03-08', '2021-03-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P014', 'T005', 'H142', '2021-03-09', '2021-03-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P024', 'T005', 'H143', '2021-03-10', '2021-03-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P033', 'T005', 'H144', '2021-03-11', '2021-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P206', 'T005', 'G240', '2021-03-08', '2021-03-13', 'checked_out');
INSERT INTO public.accommodation VALUES ('P225', 'T005', 'G241', '2021-03-10', '2021-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P252', 'T005', 'G242', '2021-03-07', '2021-03-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P019', 'T006', 'H150', '2021-09-09', '2021-09-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P026', 'T006', 'H151', '2021-09-10', '2021-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P037', 'T006', 'H152', '2021-09-11', '2021-09-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P040', 'T006', 'H153', '2021-09-12', '2021-09-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P043', 'T006', 'H154', '2021-09-13', '2021-09-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P219', 'T006', 'G250', '2021-09-10', '2021-09-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P228', 'T006', 'G251', '2021-09-08', '2021-09-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P273', 'T006', 'G252', '2021-09-11', '2021-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P009', 'T007', 'H160', '2022-03-04', '2022-03-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P016', 'T007', 'H161', '2022-03-05', '2022-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P022', 'T007', 'H162', '2022-03-06', '2022-03-14', 'checked_out');
INSERT INTO public.accommodation VALUES ('P036', 'T007', 'H163', '2022-03-07', '2022-03-13', 'checked_out');
INSERT INTO public.accommodation VALUES ('P049', 'T007', 'H164', '2022-03-08', '2022-03-12', 'checked_out');
INSERT INTO public.accommodation VALUES ('P201', 'T007', 'G260', '2022-03-05', '2022-03-11', 'checked_out');
INSERT INTO public.accommodation VALUES ('P217', 'T007', 'G261', '2022-03-04', '2022-03-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P277', 'T007', 'G262', '2022-03-07', '2022-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P010', 'T008', 'H170', '2022-09-11', '2022-09-23', 'checked_out');
INSERT INTO public.accommodation VALUES ('P025', 'T008', 'H171', '2022-09-12', '2022-09-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P041', 'T008', 'H172', '2022-09-13', '2022-09-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P046', 'T008', 'H173', '2022-09-14', '2022-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P060', 'T008', 'H174', '2022-09-15', '2022-09-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P205', 'T008', 'G270', '2022-09-12', '2022-09-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P248', 'T008', 'G271', '2022-09-11', '2022-09-23', 'checked_out');
INSERT INTO public.accommodation VALUES ('P266', 'T008', 'G272', '2022-09-14', '2022-09-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P006', 'T009', 'H180', '2023-03-06', '2023-03-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P012', 'T009', 'H181', '2023-03-07', '2023-03-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P033', 'T009', 'H182', '2023-03-08', '2023-03-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P049', 'T009', 'H183', '2023-03-09', '2023-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P052', 'T009', 'H184', '2023-03-10', '2023-03-14', 'checked_out');
INSERT INTO public.accommodation VALUES ('P207', 'T009', 'G280', '2023-03-07', '2023-03-12', 'checked_out');
INSERT INTO public.accommodation VALUES ('P253', 'T009', 'G281', '2023-03-09', '2023-03-15', 'checked_out');
INSERT INTO public.accommodation VALUES ('P294', 'T009', 'G282', '2023-03-08', '2023-03-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P003', 'T010', 'H190', '2023-09-08', '2023-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P014', 'T010', 'H191', '2023-09-09', '2023-09-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P028', 'T010', 'H192', '2023-09-10', '2023-09-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P036', 'T010', 'H193', '2023-09-11', '2023-09-17', 'checked_out');
INSERT INTO public.accommodation VALUES ('P065', 'T010', 'H194', '2023-09-12', '2023-09-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P202', 'T010', 'G290', '2023-09-09', '2023-09-14', 'checked_out');
INSERT INTO public.accommodation VALUES ('P233', 'T010', 'G291', '2023-09-10', '2023-09-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P280', 'T010', 'G292', '2023-09-08', '2023-09-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P001', 'T011', 'H201', '2024-03-10', '2024-03-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P005', 'T011', 'H202', '2024-03-11', '2024-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P011', 'T011', 'H203', '2024-03-12', '2024-03-20', 'checked_out');
INSERT INTO public.accommodation VALUES ('P020', 'T011', 'H204', '2024-03-13', '2024-03-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P050', 'T011', 'H205', '2024-03-14', '2024-03-18', 'checked_out');
INSERT INTO public.accommodation VALUES ('P204', 'T011', 'G301', '2024-03-11', '2024-03-16', 'checked_out');
INSERT INTO public.accommodation VALUES ('P259', 'T011', 'G302', '2024-03-10', '2024-03-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P281', 'T011', 'G303', '2024-03-13', '2024-03-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P002', 'T012', 'H210', '2024-09-13', '2024-09-25', 'checked_out');
INSERT INTO public.accommodation VALUES ('P007', 'T012', 'H211', '2024-09-14', '2024-09-24', 'checked_out');
INSERT INTO public.accommodation VALUES ('P015', 'T012', 'H212', '2024-09-15', '2024-09-23', 'checked_out');
INSERT INTO public.accommodation VALUES ('P023', 'T012', 'H213', '2024-09-16', '2024-09-22', 'checked_out');
INSERT INTO public.accommodation VALUES ('P031', 'T012', 'H214', '2024-09-17', '2024-09-21', 'checked_out');
INSERT INTO public.accommodation VALUES ('P216', 'T012', 'G310', '2024-09-14', '2024-09-19', 'checked_out');
INSERT INTO public.accommodation VALUES ('P230', 'T012', 'G311', '2024-09-13', '2024-09-25', 'checked_out');
INSERT INTO public.accommodation VALUES ('P287', 'T012', 'G312', '2024-09-16', '2024-09-24', 'checked_out');
INSERT INTO public.accommodation VALUES ('P004', 'T013', 'H220', '2025-03-08', '2025-03-20', 'booked');
INSERT INTO public.accommodation VALUES ('P009', 'T013', 'H221', '2025-03-09', '2025-03-19', 'booked');
INSERT INTO public.accommodation VALUES ('P017', 'T013', 'H222', '2025-03-10', '2025-03-18', 'booked');
INSERT INTO public.accommodation VALUES ('P030', 'T013', 'H223', '2025-03-11', '2025-03-17', 'booked');
INSERT INTO public.accommodation VALUES ('P048', 'T013', 'H224', '2025-03-12', '2025-03-16', 'booked');
INSERT INTO public.accommodation VALUES ('P203', 'T013', 'G320', '2025-03-09', '2025-03-14', 'booked');
INSERT INTO public.accommodation VALUES ('P212', 'T013', 'G321', '2025-03-08', '2025-03-20', 'booked');
INSERT INTO public.accommodation VALUES ('P257', 'T013', 'G322', '2025-03-11', '2025-03-19', 'booked');
INSERT INTO public.accommodation VALUES ('P006', 'T014', 'H230', '2025-09-15', '2025-09-27', 'booked');
INSERT INTO public.accommodation VALUES ('P013', 'T014', 'H231', '2025-09-16', '2025-09-26', 'booked');
INSERT INTO public.accommodation VALUES ('P021', 'T014', 'H232', '2025-09-17', '2025-09-25', 'booked');
INSERT INTO public.accommodation VALUES ('P034', 'T014', 'H233', '2025-09-18', '2025-09-24', 'booked');
INSERT INTO public.accommodation VALUES ('P037', 'T014', 'H234', '2025-09-19', '2025-09-23', 'booked');
INSERT INTO public.accommodation VALUES ('P213', 'T014', 'G330', '2025-09-16', '2025-09-21', 'booked');
INSERT INTO public.accommodation VALUES ('P216', 'T014', 'G331', '2025-09-15', '2025-09-27', 'booked');
INSERT INTO public.accommodation VALUES ('P245', 'T014', 'G332', '2025-09-18', '2025-09-26', 'booked');


--
-- Data for Name: coach; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.coach VALUES ('C001', 'Rajesh Patel', '9876500001');
INSERT INTO public.coach VALUES ('C002', 'Sonal Desai', '9876500002');
INSERT INTO public.coach VALUES ('C003', 'Vikas Sharma', '9876500003');
INSERT INTO public.coach VALUES ('C004', 'Priya Menon', '9876500004');
INSERT INTO public.coach VALUES ('C005', 'Manish Trivedi', '9876500005');
INSERT INTO public.coach VALUES ('C006', 'Rita Joshi', '9876500006');
INSERT INTO public.coach VALUES ('C007', 'Ajay Bhatia', '9876500007');
INSERT INTO public.coach VALUES ('C008', 'Neha Kapoor', '9876500008');
INSERT INTO public.coach VALUES ('C009', 'Kiran Chauhan', '9876500009');
INSERT INTO public.coach VALUES ('C010', 'Deepak Verma', '9876500010');
INSERT INTO public.coach VALUES ('C011', 'Nidhi Iyer', '9876500011');
INSERT INTO public.coach VALUES ('C012', 'Amit Gaur', '9876500012');
INSERT INTO public.coach VALUES ('C013', 'Sanjay Rao', '9876500013');
INSERT INTO public.coach VALUES ('C014', 'Sneha Tiwari', '9876500014');
INSERT INTO public.coach VALUES ('C015', 'Kunal Mehta', '9876500015');


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.company VALUES ('Amul India', 'Amul Dairy Road, Anand, Gujarat');
INSERT INTO public.company VALUES ('Zydus Wellness', 'Zydus Tower, Satellite, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Adani Sports Foundation', 'Adani Shantigram, SG Highway, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Reliance Foundation', 'Maker Chambers IV, Nariman Point, Mumbai, Maharashtra');
INSERT INTO public.company VALUES ('Torrent Power', 'Torrent House, Ashram Road, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Nirma Ltd', 'Nirma University Campus, Sarkhej-Gandhinagar Highway, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('TCS Gandhinagar', 'Infocity Campus, Gandhinagar, Gujarat');
INSERT INTO public.company VALUES ('ICICI Foundation', 'ICICI Tower, Bandra Kurla Complex, Mumbai, Maharashtra');
INSERT INTO public.company VALUES ('Axis Bank CSR', 'Axis House, Worli, Mumbai, Maharashtra');
INSERT INTO public.company VALUES ('Wagh Bakri Tea Group', 'Wagh Bakri House, Ambawadi, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Infosys Foundation', 'Electronics City Campus, Bangalore, Karnataka');
INSERT INTO public.company VALUES ('HDFC CSR', 'HDFC House, Nariman Point, Mumbai, Maharashtra');
INSERT INTO public.company VALUES ('Cadila Pharmaceuticals', 'Dholka Road, Bhat, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Gujarat Gas Ltd', 'GGL House, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Larsen & Toubro', 'L&T Knowledge City, Vadodara, Gujarat');
INSERT INTO public.company VALUES ('ONGC', 'ONGC Nagar, Mehsana, Gujarat');
INSERT INTO public.company VALUES ('Parle Agro', 'Western Express Highway, Andheri East, Mumbai, Maharashtra');
INSERT INTO public.company VALUES ('Tata Motors', 'Sanand Plant, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Einfochips', 'Satellite, Ahmedabad, Gujarat');
INSERT INTO public.company VALUES ('Suzlon Energy', 'Suzlon One Earth, Pune, Maharashtra');


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.equipments VALUES ('E001', 'Football', 15);
INSERT INTO public.equipments VALUES ('E002', 'Goal Nets', 4);
INSERT INTO public.equipments VALUES ('E003', 'Corner Flags', 8);
INSERT INTO public.equipments VALUES ('E004', 'Basketballs', 20);
INSERT INTO public.equipments VALUES ('E005', 'Hoops and Backboards', 2);
INSERT INTO public.equipments VALUES ('E006', 'Scoreboard', 1);
INSERT INTO public.equipments VALUES ('E007', 'Tennis Rackets', 12);
INSERT INTO public.equipments VALUES ('E008', 'Tennis Balls', 60);
INSERT INTO public.equipments VALUES ('E009', 'Nets', 2);
INSERT INTO public.equipments VALUES ('E010', 'Chess Boards', 20);
INSERT INTO public.equipments VALUES ('E011', 'Chess Clocks', 10);
INSERT INTO public.equipments VALUES ('E012', 'Cricket Bats', 12);
INSERT INTO public.equipments VALUES ('E013', 'Cricket Balls', 24);
INSERT INTO public.equipments VALUES ('E014', 'Wickets Sets', 6);
INSERT INTO public.equipments VALUES ('E015', 'Pads and Gloves Sets', 10);
INSERT INTO public.equipments VALUES ('E016', 'Badminton Rackets', 16);
INSERT INTO public.equipments VALUES ('E017', 'Shuttlecocks', 100);
INSERT INTO public.equipments VALUES ('E018', 'Badminton Nets', 4);
INSERT INTO public.equipments VALUES ('E019', 'Carrom Boards', 10);
INSERT INTO public.equipments VALUES ('E020', 'Strikers', 20);
INSERT INTO public.equipments VALUES ('E021', 'Carrom Coins Sets', 30);
INSERT INTO public.equipments VALUES ('E022', 'TT Tables', 6);
INSERT INTO public.equipments VALUES ('E023', 'TT Bats', 20);
INSERT INTO public.equipments VALUES ('E024', 'TT Balls', 100);
INSERT INTO public.equipments VALUES ('E025', 'Volleyballs', 15);
INSERT INTO public.equipments VALUES ('E026', 'Nets', 3);
INSERT INTO public.equipments VALUES ('E027', 'Boundary Markers', 6);
INSERT INTO public.equipments VALUES ('E028', 'Weight Plates', 50);
INSERT INTO public.equipments VALUES ('E029', 'Barbells', 10);
INSERT INTO public.equipments VALUES ('E030', 'Benches', 5);


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.match VALUES ('M001', 'SP001', 'T001', '2019-03-11', 'Group', '10:00:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M002', 'SP005', 'T001', '2019-03-13', 'Group', '13:30:00', 'V005', 'R002');
INSERT INTO public.match VALUES ('M003', 'SP002', 'T001', '2019-03-15', 'Quarterfinal', '17:00:00', 'V007', 'R003');
INSERT INTO public.match VALUES ('M004', 'SP006', 'T001', '2019-03-17', 'Semifinal', '18:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M005', 'SP003', 'T001', '2019-03-20', 'Final', '11:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M006', 'SP009', 'T002', '2019-09-16', 'Group', '09:00:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M007', 'SP008', 'T002', '2019-09-17', 'Group', '15:45:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M008', 'SP004', 'T002', '2019-09-19', 'Quarterfinal', '10:30:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M009', 'SP010', 'T002', '2019-09-22', 'Semifinal', '19:00:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M010', 'SP007', 'T002', '2019-09-25', 'Final', '16:00:00', 'V009', 'R010');
INSERT INTO public.match VALUES ('M011', 'SP001', 'T003', '2020-03-13', 'Group', '11:30:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M012', 'SP002', 'T003', '2020-03-14', 'Group', '16:00:00', 'V007', 'R002');
INSERT INTO public.match VALUES ('M013', 'SP005', 'T003', '2020-03-16', 'Quarterfinal', '14:00:00', 'V005', 'R003');
INSERT INTO public.match VALUES ('M014', 'SP006', 'T003', '2020-03-18', 'Semifinal', '17:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M015', 'SP003', 'T003', '2020-03-21', 'Final', '12:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M016', 'SP009', 'T004', '2020-09-19', 'Group', '08:30:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M017', 'SP008', 'T004', '2020-09-21', 'Group', '15:00:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M018', 'SP004', 'T004', '2020-09-24', 'Quarterfinal', '11:00:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M019', 'SP010', 'T004', '2020-09-26', 'Semifinal', '19:30:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M020', 'SP007', 'T004', '2020-09-28', 'Final', '16:30:00', 'V009', 'R010');
INSERT INTO public.match VALUES ('M021', 'SP001', 'T005', '2021-03-09', 'Group', '10:00:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M022', 'SP005', 'T005', '2021-03-10', 'Group', '13:30:00', 'V005', 'R002');
INSERT INTO public.match VALUES ('M023', 'SP002', 'T005', '2021-03-12', 'Quarterfinal', '17:00:00', 'V007', 'R003');
INSERT INTO public.match VALUES ('M024', 'SP006', 'T005', '2021-03-14', 'Semifinal', '18:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M025', 'SP003', 'T005', '2021-03-17', 'Final', '11:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M026', 'SP009', 'T006', '2021-09-11', 'Group', '09:00:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M027', 'SP008', 'T006', '2021-09-13', 'Group', '15:45:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M028', 'SP004', 'T006', '2021-09-15', 'Quarterfinal', '10:30:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M029', 'SP010', 'T006', '2021-09-17', 'Semifinal', '19:00:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M030', 'SP007', 'T006', '2021-09-20', 'Final', '16:00:00', 'V009', 'R010');
INSERT INTO public.match VALUES ('M031', 'SP001', 'T007', '2022-03-06', 'Group', '11:30:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M032', 'SP002', 'T007', '2022-03-08', 'Group', '16:00:00', 'V007', 'R002');
INSERT INTO public.match VALUES ('M033', 'SP005', 'T007', '2022-03-10', 'Quarterfinal', '14:00:00', 'V005', 'R003');
INSERT INTO public.match VALUES ('M034', 'SP006', 'T007', '2022-03-12', 'Semifinal', '17:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M035', 'SP003', 'T007', '2022-03-15', 'Final', '12:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M036', 'SP009', 'T008', '2022-09-13', 'Group', '08:30:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M037', 'SP008', 'T008', '2022-09-15', 'Group', '15:00:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M038', 'SP004', 'T008', '2022-09-17', 'Quarterfinal', '11:00:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M039', 'SP010', 'T008', '2022-09-19', 'Semifinal', '19:30:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M040', 'SP007', 'T008', '2022-09-22', 'Final', '16:30:00', 'V009', 'R010');
INSERT INTO public.match VALUES ('M041', 'SP001', 'T009', '2023-03-08', 'Group', '10:00:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M042', 'SP005', 'T009', '2023-03-10', 'Group', '13:30:00', 'V005', 'R002');
INSERT INTO public.match VALUES ('M043', 'SP002', 'T009', '2023-03-12', 'Quarterfinal', '17:00:00', 'V007', 'R003');
INSERT INTO public.match VALUES ('M044', 'SP006', 'T009', '2023-03-14', 'Semifinal', '18:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M045', 'SP003', 'T009', '2023-03-17', 'Final', '11:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M046', 'SP009', 'T010', '2023-09-10', 'Group', '09:00:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M047', 'SP008', 'T010', '2023-09-12', 'Group', '15:45:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M048', 'SP004', 'T010', '2023-09-14', 'Quarterfinal', '10:30:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M049', 'SP010', 'T010', '2023-09-16', 'Semifinal', '19:00:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M050', 'SP007', 'T010', '2023-09-19', 'Final', '16:00:00', 'V009', 'R010');
INSERT INTO public.match VALUES ('M051', 'SP001', 'T011', '2024-03-12', 'Group', '11:30:00', 'V006', 'R001');
INSERT INTO public.match VALUES ('M052', 'SP002', 'T011', '2024-03-14', 'Group', '16:00:00', 'V007', 'R002');
INSERT INTO public.match VALUES ('M053', 'SP005', 'T011', '2024-03-16', 'Quarterfinal', '14:00:00', 'V005', 'R003');
INSERT INTO public.match VALUES ('M054', 'SP006', 'T011', '2024-03-18', 'Semifinal', '17:30:00', 'V011', 'R004');
INSERT INTO public.match VALUES ('M055', 'SP003', 'T011', '2024-03-21', 'Final', '12:00:00', 'V003', 'R005');
INSERT INTO public.match VALUES ('M056', 'SP009', 'T012', '2024-09-15', 'Group', '08:30:00', 'V008', 'R006');
INSERT INTO public.match VALUES ('M057', 'SP008', 'T012', '2024-09-17', 'Group', '15:00:00', 'V004', 'R007');
INSERT INTO public.match VALUES ('M058', 'SP004', 'T012', '2024-09-20', 'Quarterfinal', '11:00:00', 'V010', 'R008');
INSERT INTO public.match VALUES ('M059', 'SP010', 'T012', '2024-09-22', 'Semifinal', '19:30:00', 'V013', 'R009');
INSERT INTO public.match VALUES ('M060', 'SP007', 'T012', '2024-09-24', 'Final', '16:30:00', 'V009', 'R010');


--
-- Data for Name: organizer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.organizer VALUES ('O001', 'Reemi Patel', '9876500201');
INSERT INTO public.organizer VALUES ('O002', 'Pransi Patel', '9876500202');
INSERT INTO public.organizer VALUES ('O003', 'Rohan Shah', '9876500203');
INSERT INTO public.organizer VALUES ('O004', 'Neel Trivedi', '9876500204');
INSERT INTO public.organizer VALUES ('O005', 'Khushi Mehta', '9876500205');
INSERT INTO public.organizer VALUES ('O006', 'Jay Soni', '9876500206');
INSERT INTO public.organizer VALUES ('O007', 'Isha Bhatt', '9876500207');
INSERT INTO public.organizer VALUES ('O008', 'Harsh Desai', '9876500208');
INSERT INTO public.organizer VALUES ('O009', 'Sanya Shah', '9876500209');
INSERT INTO public.organizer VALUES ('O010', 'Aaryan Joshi', '9876500210');
INSERT INTO public.organizer VALUES ('O011', 'Tanishka Dave', '9876500211');
INSERT INTO public.organizer VALUES ('O012', 'Pratham Patel', '9876500212');
INSERT INTO public.organizer VALUES ('O013', 'Shruti Vora', '9876500213');
INSERT INTO public.organizer VALUES ('O014', 'Dhruv Parmar', '9876500214');
INSERT INTO public.organizer VALUES ('O015', 'Kavya Bhimani', '9876500215');


--
-- Data for Name: organizetournament; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.organizetournament VALUES ('T001', 'O001', 'Coordinator', 'Operations');
INSERT INTO public.organizetournament VALUES ('T001', 'O002', 'Manager', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T001', 'O003', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T001', 'O004', 'Volunteer', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T001', 'O005', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T001', 'O008', 'Volunteer', 'Operations');
INSERT INTO public.organizetournament VALUES ('T001', 'O013', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T002', 'O001', 'Manager', 'Operations');
INSERT INTO public.organizetournament VALUES ('T002', 'O006', 'Coordinator', 'Finance');
INSERT INTO public.organizetournament VALUES ('T002', 'O007', 'Volunteer', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T002', 'O008', 'Volunteer', 'Technical');
INSERT INTO public.organizetournament VALUES ('T002', 'O009', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T002', 'O010', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T002', 'O014', 'Assistant', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T003', 'O002', 'Coordinator', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T003', 'O003', 'Manager', 'Operations');
INSERT INTO public.organizetournament VALUES ('T003', 'O005', 'Coordinator', 'Finance');
INSERT INTO public.organizetournament VALUES ('T003', 'O010', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T003', 'O011', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T003', 'O012', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T003', 'O015', 'Volunteer', 'Operations');
INSERT INTO public.organizetournament VALUES ('T004', 'O004', 'Manager', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T004', 'O005', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T004', 'O006', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T004', 'O013', 'Assistant', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T004', 'O014', 'Volunteer', 'Technical');
INSERT INTO public.organizetournament VALUES ('T004', 'O015', 'Coordinator', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T004', 'O007', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T005', 'O001', 'Volunteer', 'Finance');
INSERT INTO public.organizetournament VALUES ('T005', 'O006', 'Coordinator', 'Finance');
INSERT INTO public.organizetournament VALUES ('T005', 'O007', 'Manager', 'Technical');
INSERT INTO public.organizetournament VALUES ('T005', 'O008', 'Coordinator', 'Operations');
INSERT INTO public.organizetournament VALUES ('T005', 'O009', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T005', 'O010', 'Assistant', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T005', 'O012', 'Volunteer', 'Operations');
INSERT INTO public.organizetournament VALUES ('T006', 'O011', 'Manager', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T006', 'O012', 'Coordinator', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T006', 'O013', 'Coordinator', 'Finance');
INSERT INTO public.organizetournament VALUES ('T006', 'O014', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T006', 'O015', 'Assistant', 'Operations');
INSERT INTO public.organizetournament VALUES ('T006', 'O002', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T006', 'O004', 'Coordinator', 'Technical');
INSERT INTO public.organizetournament VALUES ('T007', 'O001', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T007', 'O003', 'Manager', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T007', 'O005', 'Volunteer', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T007', 'O007', 'Volunteer', 'Operations');
INSERT INTO public.organizetournament VALUES ('T007', 'O009', 'Coordinator', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T007', 'O011', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T007', 'O013', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T008', 'O002', 'Manager', 'Finance');
INSERT INTO public.organizetournament VALUES ('T008', 'O004', 'Coordinator', 'Technical');
INSERT INTO public.organizetournament VALUES ('T008', 'O006', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T008', 'O008', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T008', 'O010', 'Assistant', 'Operations');
INSERT INTO public.organizetournament VALUES ('T008', 'O012', 'Volunteer', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T008', 'O014', 'Volunteer', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T009', 'O001', 'Manager', 'Operations');
INSERT INTO public.organizetournament VALUES ('T009', 'O003', 'Coordinator', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T009', 'O005', 'Volunteer', 'Technical');
INSERT INTO public.organizetournament VALUES ('T009', 'O011', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T009', 'O013', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T009', 'O015', 'Assistant', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T009', 'O007', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T010', 'O002', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T010', 'O004', 'Manager', 'Operations');
INSERT INTO public.organizetournament VALUES ('T010', 'O005', 'Assistant', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T010', 'O012', 'Volunteer', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T010', 'O014', 'Coordinator', 'Technical');
INSERT INTO public.organizetournament VALUES ('T010', 'O001', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T010', 'O008', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T011', 'O006', 'Manager', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T011', 'O007', 'Coordinator', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T011', 'O008', 'Assistant', 'Finance');
INSERT INTO public.organizetournament VALUES ('T011', 'O009', 'Volunteer', 'Technical');
INSERT INTO public.organizetournament VALUES ('T011', 'O010', 'Coordinator', 'Operations');
INSERT INTO public.organizetournament VALUES ('T011', 'O013', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T011', 'O015', 'Coordinator', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T012', 'O003', 'Volunteer', 'Operations');
INSERT INTO public.organizetournament VALUES ('T012', 'O011', 'Coordinator', 'Technical');
INSERT INTO public.organizetournament VALUES ('T012', 'O012', 'Manager', 'Operations');
INSERT INTO public.organizetournament VALUES ('T012', 'O013', 'Assistant', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T012', 'O014', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T012', 'O015', 'Coordinator', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T012', 'O006', 'Volunteer', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T013', 'O001', 'Manager', 'Finance');
INSERT INTO public.organizetournament VALUES ('T013', 'O002', 'Coordinator', 'Hospitality');
INSERT INTO public.organizetournament VALUES ('T013', 'O003', 'Coordinator', 'Technical');
INSERT INTO public.organizetournament VALUES ('T013', 'O004', 'Volunteer', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T013', 'O005', 'Assistant', 'Operations');
INSERT INTO public.organizetournament VALUES ('T013', 'O009', 'Volunteer', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T013', 'O011', 'Coordinator', 'Operations');
INSERT INTO public.organizetournament VALUES ('T014', 'O006', 'Coordinator', 'Operations');
INSERT INTO public.organizetournament VALUES ('T014', 'O007', 'Manager', 'Marketing');
INSERT INTO public.organizetournament VALUES ('T014', 'O008', 'Volunteer', 'Finance');
INSERT INTO public.organizetournament VALUES ('T014', 'O009', 'Volunteer', 'Volunteers');
INSERT INTO public.organizetournament VALUES ('T014', 'O010', 'Coordinator', 'Logistics');
INSERT INTO public.organizetournament VALUES ('T014', 'O013', 'Assistant', 'Technical');
INSERT INTO public.organizetournament VALUES ('T014', 'O014', 'Coordinator', 'Marketing');


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.person VALUES ('P001', 'Aarav Patel', 'Male', '2003-04-15', '9876500001', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P002', 'Rohan Mehta', 'Male', '2002-07-22', '9876500002', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P003', 'Ishita Shah', 'Female', '2004-02-10', '9876500003', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P004', 'Neel Desai', 'Male', '2003-09-28', '9876500004', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P005', 'Dhruv Joshi', 'Male', '2001-12-05', '9876500005', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P006', 'Ananya Trivedi', 'Female', '2004-05-18', '9876500006', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P007', 'Harsh Pandya', 'Male', '2002-11-09', '9876500007', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P008', 'Kavya Shah', 'Female', '2003-03-14', '9876500008', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P009', 'Yash Rajput', 'Male', '2004-01-20', '9876500009', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P010', 'Riya Bhatt', 'Female', '2004-07-02', '9876500010', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P011', 'Aditya Nair', 'Male', '2001-06-30', '9876500011', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P012', 'Simran Kaur', 'Female', '2006-10-05', '9876500012', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P013', 'Manav Sharma', 'Male', '2003-01-19', '9876500013', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P014', 'Priya Deshmukh', 'Female', '2002-05-27', '9876500014', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P015', 'Arjun Reddy', 'Male', '2001-03-12', '9876500015', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P016', 'Sneha Pillai', 'Female', '2004-08-08', '9876500016', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P017', 'Ritik Verma', 'Male', '2002-12-16', '9876500017', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P018', 'Tanya Jain', 'Female', '2003-02-04', '9876500018', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P019', 'Kunal Sinha', 'Male', '2004-03-09', '9876500019', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P020', 'Megha Iyer', 'Female', '2001-07-21', '9876500020', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P021', 'Nikhil Chauhan', 'Male', '2003-10-01', '9876500021', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P022', 'Diya Patel', 'Female', '2004-06-06', '9876500022', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P023', 'Vivek Gupta', 'Male', '2002-02-24', '9876500023', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P024', 'Aditi Rao', 'Female', '2003-11-13', '9876500024', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P025', 'Sahil Kapoor', 'Male', '2004-09-05', '9876500025', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P026', 'Nisha Menon', 'Female', '2003-05-11', '9876500026', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P027', 'Yuvraj Singh', 'Male', '2002-08-30', '9876500027', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P028', 'Rachita Ghosh', 'Female', '2001-04-07', '9876500028', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P029', 'Varun Malhotra', 'Male', '2004-02-22', '9876500029', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P030', 'Shreya Bansal', 'Female', '2002-06-18', '9876500030', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P031', 'Ankit Sharma', 'Male', '2001-09-12', '9876500031', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P032', 'Kritika Chawla', 'Female', '2003-01-25', '9876500032', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P033', 'Dev Patel', 'Male', '2004-03-03', '9876500033', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P034', 'Snehal Shah', 'Female', '2002-07-16', '9876500034', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P035', 'Parth Gajjar', 'Male', '2003-12-29', '9876500035', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P036', 'Ankita Mehta', 'Female', '2004-10-14', '9876500036', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P037', 'Rahul Jain', 'Male', '2001-08-19', '9876500037', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P038', 'Mitali Nair', 'Female', '2004-05-25', '9876500038', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P039', 'Jay Desai', 'Male', '2002-09-02', '9876500039', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P040', 'Isha Kapoor', 'Female', '2003-11-07', '9876500040', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P041', 'Rohit Bansal', 'Male', '2004-04-13', '9876500041', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P042', 'Aanya Shetty', 'Female', '2001-02-10', '9876500042', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P043', 'Karan Tiwari', 'Male', '2004-08-01', '9876500043', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P044', 'Nidhi Deshmukh', 'Female', '2002-01-05', '9876500044', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P045', 'Ritesh Jha', 'Male', '2003-06-20', '9876500045', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P046', 'Aarohi Mehta', 'Female', '2004-09-09', '9876500046', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P047', 'Mohit Kumar', 'Male', '2002-10-18', '9876500047', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P048', 'Jahnavi Joshi', 'Female', '2003-07-27', '9876500048', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P049', 'Tushar Jain', 'Male', '2004-12-15', '9876500049', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P050', 'Pooja Shah', 'Female', '2001-03-08', '9876500050', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P051', 'Samar Vora', 'Male', '2002-08-03', '9876500051', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P052', 'Sanya Patel', 'Female', '2004-06-12', '9876500052', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P053', 'Dhruv Trivedi', 'Male', '2001-09-11', '9876500053', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P054', 'Ira Choksi', 'Female', '2003-05-09', '9876500054', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P055', 'Rachit Jain', 'Male', '2004-07-14', '9876500055', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P056', 'Neha Sharma', 'Female', '2002-11-29', '9876500056', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P057', 'Saurabh Singh', 'Male', '2003-01-02', '9876500057', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P058', 'Aarohi Nanda', 'Female', '2004-10-27', '9876500058', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P059', 'Karan Gohil', 'Male', '2002-04-23', '9876500059', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P060', 'Anushka Vyas', 'Female', '2004-12-11', '9876500060', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P061', 'Hardik Patel', 'Male', '2001-07-18', '9876500061', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P062', 'Sneha Shukla', 'Female', '2004-09-25', '9876500062', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P063', 'Arjun Soni', 'Male', '2003-06-17', '9876500063', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P064', 'Kritika Joshi', 'Female', '2004-02-02', '9876500064', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P065', 'Pranav Modi', 'Male', '2002-05-05', '9876500065', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P066', 'Nisha Raval', 'Female', '2003-09-08', '9876500066', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P067', 'Mihir Shah', 'Male', '2001-10-15', '9876500067', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P068', 'Riya Trivedi', 'Female', '2004-03-28', '9876500068', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P069', 'Rudra Bhatt', 'Male', '2004-05-30', '9876500069', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P070', 'Jiya Mehta', 'Female', '2002-12-04', '9876500070', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P071', 'Nirav Patel', 'Male', '2003-08-20', '9876500071', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P072', 'Tanvi Ghosh', 'Female', '2004-10-07', '9876500072', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P073', 'Raj Deshmukh', 'Male', '2002-02-25', '9876500073', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P074', 'Aisha Khan', 'Female', '2003-04-19', '9876500074', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P075', 'Jay Mehta', 'Male', '2001-06-16', '9876500075', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P076', 'Manya Patel', 'Female', '2003-09-10', '9876500076', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P077', 'Aman Sharma', 'Male', '2004-08-15', '9876500077', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P078', 'Harini Iyer', 'Female', '2002-03-14', '9876500078', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P079', 'Dharmik Bhavsar', 'Male', '2003-11-29', '9876500079', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P080', 'Ritika Dave', 'Female', '2004-07-03', '9876500080', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P081', 'Krish Parekh', 'Male', '2002-01-23', '9876500081', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P082', 'Pooja Shetty', 'Female', '2004-05-27', '9876500082', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P083', 'Yash Mahajan', 'Male', '2001-12-19', '9876500083', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P084', 'Snehal Solanki', 'Female', '2004-09-11', '9876500084', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P085', 'Kushal Patel', 'Male', '2003-03-17', '9876500085', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P086', 'Anvi Desai', 'Female', '2004-04-22', '9876500086', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P087', 'Ritesh Purohit', 'Male', '2001-07-06', '9876500087', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P088', 'Nidhi Kothari', 'Female', '2003-10-30', '9876500088', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P089', 'Tirth Patel', 'Male', '2002-09-09', '9876500089', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P090', 'Aanya Vora', 'Female', '2004-11-21', '9876500090', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P091', 'Harshil Mehta', 'Male', '2003-08-25', '9876500091', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P092', 'Kavisha Nair', 'Female', '2002-06-13', '9876500092', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P093', 'Manan Shah', 'Male', '2004-03-05', '9876500093', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P094', 'Dhriti Patel', 'Female', '2003-01-08', '9876500094', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P095', 'Yug Thakkar', 'Male', '2002-02-14', '9876500095', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P096', 'Mahi Choksi', 'Female', '2004-10-02', '9876500096', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P097', 'Vansh Gajjar', 'Male', '2001-11-11', '9876500097', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P098', 'Rashmi Jain', 'Female', '2004-09-23', '9876500098', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P099', 'Chirag Patel', 'Male', '2003-07-18', '9876500099', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P100', 'Shruti Nanda', 'Female', '2002-12-27', '9876500100', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P101', 'Aarav Mehta', 'Male', '2002-05-14', '9876500101', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P102', 'Isha Patel', 'Female', '2003-07-21', '9876500102', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P103', 'Rohan Sharma', 'Male', '2001-09-11', '9876500103', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P104', 'Diya Desai', 'Female', '2002-03-05', '9876500104', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P105', 'Krish Shah', 'Male', '2000-10-09', '9876500105', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P106', 'Aanya Iyer', 'Female', '2001-01-25', '9876500106', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P107', 'Vihaan Trivedi', 'Male', '2004-12-12', '9876500107', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P108', 'Mahi Joshi', 'Female', '2003-02-10', '9876500108', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P109', 'Dev Parmar', 'Male', '2001-06-15', '9876500109', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P110', 'Kavya Bhatt', 'Female', '2000-09-09', '9876500110', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P111', 'Harsh Rana', 'Male', '2002-07-13', '9876500111', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P112', 'Tanya Gohil', 'Female', '2001-11-02', '9876500112', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P113', 'Yash Vora', 'Male', '2003-08-18', '9876500113', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P114', 'Niyati Choksi', 'Female', '2005-04-14', '9876500114', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P115', 'Aarush Dave', 'Male', '2004-06-21', '9876500115', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P116', 'Meera Soni', 'Female', '2002-12-19', '9876500116', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P117', 'Laksh Patel', 'Male', '2001-02-15', '9876500117', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P118', 'Sara Bhimani', 'Female', '2000-05-28', '9876500118', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P119', 'Aditya Solanki', 'Male', '2003-01-22', '9876500119', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P120', 'Jiya Thakkar', 'Female', '2004-08-03', '9876500120', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P121', 'Arjun Deshmukh', 'Male', '2002-09-17', '9876500121', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P122', 'Riya Pandya', 'Female', '2001-07-12', '9876500122', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P123', 'Dhruv Gajjar', 'Male', '2000-03-06', '9876500123', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P124', 'Anaya Vyas', 'Female', '2002-11-29', '9876500124', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P125', 'Aryan Bhagat', 'Male', '2001-08-10', '9876500125', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P126', 'Kritika Shukla', 'Female', '2000-10-19', '9876500126', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P127', 'Parth Panchal', 'Male', '2004-03-08', '9876500127', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P128', 'Shruti Zaveri', 'Female', '2003-05-01', '9876500128', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P129', 'Karan Chauhan', 'Male', '2002-01-14', '9876500129', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P130', 'Riddhi Joshi', 'Female', '2003-07-27', '9876500130', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P131', 'Manan Rawal', 'Male', '2001-06-04', '9876500131', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P132', 'Avni Shah', 'Female', '2005-02-09', '9876500132', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P133', 'Tirth Dholakia', 'Male', '2002-12-11', '9876500133', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P134', 'Charmi Patel', 'Female', '2004-09-13', '9876500134', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P135', 'Neel Bhavsar', 'Male', '2003-04-16', '9876500135', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P136', 'Roshni Vora', 'Female', '2001-10-01', '9876500136', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P137', 'Harit Mehta', 'Male', '2000-08-22', '9876500137', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P138', 'Sneha Shah', 'Female', '2002-07-19', '9876500138', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P139', 'Rudra Joshi', 'Male', '2001-05-09', '9876500139', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P140', 'Mitali Rana', 'Female', '2004-03-20', '9876500140', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P141', 'Devang Thakar', 'Male', '2005-04-18', '9876500141', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P142', 'Anjali Gohil', 'Female', '2002-06-22', '9876500142', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P143', 'Jay Solanki', 'Male', '2001-09-30', '9876500143', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P144', 'Prisha Mehta', 'Female', '2000-11-05', '9876500144', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P145', 'Kunal Trivedi', 'Male', '2002-12-28', '9876500145', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P146', 'Rhea Shah', 'Female', '2003-10-24', '9876500146', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P147', 'Yuvraj Patel', 'Male', '2000-02-08', '9876500147', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P148', 'Ishita Bhatt', 'Female', '2001-12-13', '9876500148', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P149', 'Raj Sheth', 'Male', '2004-05-27', '9876500149', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P150', 'Tanya Desai', 'Female', '2002-01-31', '9876500150', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P151', 'Aarav Shah', 'Male', '2002-04-15', '9876500201', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P152', 'Kiara Mehta', 'Female', '2003-09-24', '9876500202', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P153', 'Rudra Patel', 'Male', '2001-10-11', '9876500203', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P154', 'Ira Joshi', 'Female', '2002-07-09', '9876500204', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P155', 'Dev Bhavsar', 'Male', '2000-05-28', '9876500205', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P156', 'Manya Choksi', 'Female', '2001-02-12', '9876500206', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P157', 'Karan Vora', 'Male', '2003-12-23', '9876500207', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P158', 'Risha Desai', 'Female', '2000-11-08', '9876500208', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P159', 'Dhruv Panchal', 'Male', '2002-09-20', '9876500209', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P160', 'Tanya Gohil', 'Female', '2004-06-03', '9876500210', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P161', 'Jay Mehta', 'Male', '2001-04-29', '9876500211', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P162', 'Riya Trivedi', 'Female', '2000-08-21', '9876500212', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P163', 'Parth Patel', 'Male', '2003-07-19', '9876500213', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P164', 'Diya Shah', 'Female', '2005-03-04', '9876500214', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P165', 'Arjun Desai', 'Male', '2004-05-17', '9876500215', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P166', 'Sneha Iyer', 'Female', '2001-01-11', '9876500216', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P167', 'Nirav Bhatt', 'Male', '2002-06-09', '9876500217', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P168', 'Kaira Shah', 'Female', '2000-10-14', '9876500218', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P169', 'Manan Joshi', 'Male', '2001-12-20', '9876500219', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P170', 'Aanya Mehta', 'Female', '2003-02-07', '9876500220', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P171', 'Aditya Rana', 'Male', '2000-03-16', '9876500221', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P172', 'Charmi Patel', 'Female', '2001-11-24', '9876500222', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P173', 'Rohit Shah', 'Male', '2002-08-29', '9876500223', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P174', 'Niyati Vora', 'Female', '2004-10-12', '9876500224', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P175', 'Yash Thakkar', 'Male', '2005-06-18', '9876500225', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P176', 'Mitali Bhavsar', 'Female', '2000-05-07', '9876500226', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P177', 'Aayush Dave', 'Male', '2001-09-22', '9876500227', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P178', 'Rupal Shah', 'Female', '2002-07-15', '9876500228', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P179', 'Dharmik Gohil', 'Male', '2003-01-04', '9876500229', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P180', 'Neha Solanki', 'Female', '2001-03-11', '9876500230', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P181', 'Harsh Shah', 'Male', '2002-04-30', '9876500231', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P182', 'Aarohi Bhatt', 'Female', '2003-10-22', '9876500232', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P183', 'Ritesh Mehta', 'Male', '2004-09-09', '9876500233', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P184', 'Tisha Joshi', 'Female', '2001-07-02', '9876500234', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P185', 'Devansh Desai', 'Male', '2000-01-17', '9876500235', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P186', 'Shruti Rana', 'Female', '2002-12-13', '9876500236', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P187', 'Rahil Patel', 'Male', '2003-03-28', '9876500237', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P188', 'Avni Shah', 'Female', '2001-09-14', '9876500238', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P189', 'Vivek Bhavsar', 'Male', '2000-02-27', '9876500239', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P190', 'Meera Iyer', 'Female', '2005-01-10', '9876500240', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P191', 'Kush Trivedi', 'Male', '2001-06-08', '9876500241', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P192', 'Nisha Solanki', 'Female', '2003-08-05', '9876500242', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P193', 'Pranav Joshi', 'Male', '2002-11-01', '9876500243', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P194', 'Riddhi Shah', 'Female', '2000-04-09', '9876500244', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P195', 'Aman Gajjar', 'Male', '2004-05-30', '9876500245', 'MSU Baroda', 'Player');
INSERT INTO public.person VALUES ('P196', 'Isha Patel', 'Female', '2002-03-18', '9876500246', 'DA-IICT', 'Player');
INSERT INTO public.person VALUES ('P197', 'Krish Solanki', 'Male', '2003-09-23', '9876500247', 'Nirma University', 'Player');
INSERT INTO public.person VALUES ('P198', 'Mahi Desai', 'Female', '2001-02-26', '9876500248', 'PDPU', 'Player');
INSERT INTO public.person VALUES ('P199', 'Tirth Mehta', 'Male', '2000-10-18', '9876500249', 'LDCE', 'Player');
INSERT INTO public.person VALUES ('P200', 'Kashvi Bhatt', 'Female', '2004-12-02', '9876500250', 'IIT Gandhinagar', 'Player');
INSERT INTO public.person VALUES ('P201', 'Aniket Shah', 'Male', '1995-03-12', '9876500251', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P202', 'Ritika Desai', 'Female', '1998-06-24', '9876500252', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P203', 'Mihir Patel', 'Male', '1990-02-10', '9876500253', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P204', 'Naina Joshi', 'Female', '1997-11-30', '9876500254', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P205', 'Tushar Bhatt', 'Male', '1989-04-18', '9876500255', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P206', 'Kajal Mehta', 'Female', '1992-09-22', '9876500256', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P207', 'Vivek Iyer', 'Male', '1994-05-08', '9876500257', 'SVNIT Surat', 'Spectator');
INSERT INTO public.person VALUES ('P208', 'Rupal Trivedi', 'Female', '1999-03-16', '9876500258', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P209', 'Harsh Gohil', 'Male', '1996-12-02', '9876500259', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P210', 'Avni Solanki', 'Female', '2000-10-09', '9876500260', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P211', 'Raj Mehta', 'Male', '1988-08-04', '9876500261', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P212', 'Diya Patel', 'Female', '1997-07-27', '9876500262', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P213', 'Soham Bhavsar', 'Male', '1993-02-19', '9876500263', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P214', 'Kavya Shah', 'Female', '1996-06-10', '9876500264', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P215', 'Raghav Vora', 'Male', '1995-11-01', '9876500265', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P216', 'Tanya Choksi', 'Female', '1998-01-15', '9876500266', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P217', 'Yash Rana', 'Male', '1992-04-09', '9876500267', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P218', 'Megha Desai', 'Female', '1989-09-21', '9876500268', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P219', 'Neel Panchal', 'Male', '1990-12-14', '9876500269', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P220', 'Riya Gohil', 'Female', '1994-05-26', '9876500270', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P221', 'Amit Patel', 'Male', '1997-03-04', '9876500271', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P222', 'Pooja Mehta', 'Female', '1991-08-16', '9876500272', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P223', 'Jay Bhatt', 'Male', '1987-07-03', '9876500273', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P224', 'Shruti Shah', 'Female', '1998-10-18', '9876500274', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P225', 'Krunal Iyer', 'Male', '1993-01-27', '9876500275', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P226', 'Charmi Joshi', 'Female', '1999-06-29', '9876500276', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P227', 'Pranav Desai', 'Male', '1992-02-14', '9876500277', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P228', 'Sneha Trivedi', 'Female', '1995-05-11', '9876500278', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P229', 'Kush Shah', 'Male', '1988-09-09', '9876500279', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P230', 'Riddhi Mehta', 'Female', '1993-12-25', '9876500280', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P231', 'Aditya Gohil', 'Male', '1991-04-03', '9876500281', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P232', 'Isha Bhatt', 'Female', '1999-02-08', '9876500282', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P233', 'Dhruv Patel', 'Male', '1996-08-22', '9876500283', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P234', 'Niyati Solanki', 'Female', '1994-06-06', '9876500284', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P235', 'Arnav Vora', 'Male', '1990-03-19', '9876500285', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P236', 'Mitali Shah', 'Female', '1998-07-30', '9876500286', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P237', 'Harshit Rana', 'Male', '1993-10-17', '9876500287', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P238', 'Kiara Desai', 'Female', '1989-01-05', '9876500288', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P239', 'Rajesh Bhavsar', 'Male', '1992-11-12', '9876500289', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P240', 'Tanvi Mehta', 'Female', '1995-09-02', '9876500290', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P241', 'Nirav Shah', 'Male', '1994-12-29', '9876500291', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P242', 'Mahi Patel', 'Female', '1997-06-19', '9876500292', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P243', 'Dharmik Vora', 'Male', '1990-02-24', '9876500293', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P244', 'Rupal Trivedi', 'Female', '1993-05-14', '9876500294', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P245', 'Aayush Gohil', 'Male', '1996-08-01', '9876500295', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P246', 'Mitali Bhatt', 'Female', '1998-12-23', '9876500296', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P247', 'Ritesh Desai', 'Male', '1987-04-27', '9876500297', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P248', 'Kashvi Shah', 'Female', '1999-09-07', '9876500298', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P249', 'Aman Mehta', 'Male', '1992-03-15', '9876500299', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P250', 'Neha Solanki', 'Female', '1994-07-25', '9876500300', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P251', 'Rahil Patel', 'Male', '1995-11-05', '9876500301', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P252', 'Aarohi Shah', 'Female', '1998-05-30', '9876500302', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P253', 'Devansh Bhatt', 'Male', '1989-08-14', '9876500303', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P254', 'Charmi Mehta', 'Female', '1997-12-03', '9876500304', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P255', 'Rohit Trivedi', 'Male', '1992-09-29', '9876500305', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P256', 'Shruti Desai', 'Female', '1999-10-11', '9876500306', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P257', 'Parth Shah', 'Male', '1993-04-01', '9876500307', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P258', 'Nisha Joshi', 'Female', '1996-06-28', '9876500308', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P259', 'Manan Patel', 'Male', '1988-07-22', '9876500309', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P260', 'Ira Gohil', 'Female', '1994-09-05', '9876500310', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P261', 'Aarav Mehta', 'Male', '1997-05-21', '9876500311', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P262', 'Kiara Vora', 'Female', '1995-02-13', '9876500312', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P263', 'Harshil Bhatt', 'Male', '1990-11-19', '9876500313', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P264', 'Mahi Trivedi', 'Female', '1998-01-04', '9876500314', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P265', 'Karan Shah', 'Male', '1991-08-10', '9876500315', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P266', 'Avni Patel', 'Female', '1999-12-29', '9876500316', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P267', 'Nirav Gohil', 'Male', '1989-10-23', '9876500317', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P268', 'Riya Desai', 'Female', '1996-09-18', '9876500318', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P269', 'Dhruv Mehta', 'Male', '1995-03-16', '9876500319', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P270', 'Kavya Shah', 'Female', '1992-07-09', '9876500320', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P271', 'Ritesh Patel', 'Male', '1990-05-02', '9876500321', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P272', 'Mitali Vora', 'Female', '1994-12-22', '9876500322', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P273', 'Yash Bhatt', 'Male', '1993-01-25', '9876500323', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P274', 'Sneha Solanki', 'Female', '1999-11-14', '9876500324', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P275', 'Aayush Mehta', 'Male', '1988-09-27', '9876500325', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P276', 'Tanya Desai', 'Female', '1996-06-05', '9876500326', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P277', 'Raj Patel', 'Male', '1992-10-03', '9876500327', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P278', 'Charmi Shah', 'Female', '1998-08-20', '9876500328', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P279', 'Vivek Gohil', 'Male', '1995-02-28', '9876500329', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P280', 'Nisha Bhatt', 'Female', '1993-03-17', '9876500330', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P281', 'Aditya Desai', 'Male', '1997-09-07', '9876500331', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P282', 'Rupal Mehta', 'Female', '1999-04-26', '9876500332', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P283', 'Rohit Shah', 'Male', '1990-01-10', '9876500333', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P284', 'Mahi Patel', 'Female', '1995-10-01', '9876500334', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P285', 'Dev Bhavsar', 'Male', '1992-05-16', '9876500335', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P286', 'Neha Gohil', 'Female', '1998-02-05', '9876500336', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P287', 'Aarav Vora', 'Male', '1993-11-08', '9876500337', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P288', 'Kiara Desai', 'Female', '1997-06-02', '9876500338', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P289', 'Parth Patel', 'Male', '1989-07-24', '9876500339', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P290', 'Tisha Shah', 'Female', '1994-03-11', '9876500340', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P291', 'Raghav Mehta', 'Male', '1990-09-25', '9876500341', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P292', 'Isha Solanki', 'Female', '1998-01-18', '9876500342', 'Parul University', 'Spectator');
INSERT INTO public.person VALUES ('P293', 'Manav Desai', 'Male', '1992-08-07', '9876500343', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P294', 'Shruti Bhatt', 'Female', '1996-04-22', '9876500344', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P295', 'Krunal Gohil', 'Male', '1995-02-02', '9876500345', 'PDPU', 'Spectator');
INSERT INTO public.person VALUES ('P296', 'Aanya Shah', 'Female', '1997-07-28', '9876500346', 'LDCE', 'Spectator');
INSERT INTO public.person VALUES ('P297', 'Ritesh Patel', 'Male', '1988-10-17', '9876500347', 'MSU Baroda', 'Spectator');
INSERT INTO public.person VALUES ('P298', 'Mitali Mehta', 'Female', '1999-09-03', '9876500348', 'IIT Gandhinagar', 'Spectator');
INSERT INTO public.person VALUES ('P299', 'Jay Trivedi', 'Male', '1994-05-14', '9876500349', 'DA-IICT', 'Spectator');
INSERT INTO public.person VALUES ('P300', 'Niyati Solanki', 'Female', '1993-12-27', '9876500350', 'Nirma University', 'Spectator');
INSERT INTO public.person VALUES ('P301', 'saloni', 'female', '2006-10-05', '7863020731', 'DA-IICT', 'Spectator');


--
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.player VALUES ('P001', 175.50, 70.20, 'O+', 2021);
INSERT INTO public.player VALUES ('P002', 178.00, 75.80, 'A-', 2020);
INSERT INTO public.player VALUES ('P003', 162.50, 58.00, 'B+', 2022);
INSERT INTO public.player VALUES ('P004', 181.20, 79.50, 'AB-', 2021);
INSERT INTO public.player VALUES ('P005', 170.10, 68.90, 'O-', 2019);
INSERT INTO public.player VALUES ('P006', 168.00, 61.50, 'A+', 2022);
INSERT INTO public.player VALUES ('P007', 179.50, 77.00, 'B-', 2020);
INSERT INTO public.player VALUES ('P008', 165.50, 60.50, 'O+', 2021);
INSERT INTO public.player VALUES ('P009', 183.00, 81.30, 'A+', 2022);
INSERT INTO public.player VALUES ('P010', 160.00, 57.00, 'AB+', 2022);
INSERT INTO public.player VALUES ('P011', 176.80, 73.50, 'B+', 2019);
INSERT INTO public.player VALUES ('P012', 158.50, 55.20, 'O-', 2023);
INSERT INTO public.player VALUES ('P013', 174.00, 71.10, 'A-', 2021);
INSERT INTO public.player VALUES ('P014', 166.50, 62.80, 'B-', 2020);
INSERT INTO public.player VALUES ('P015', 180.50, 78.20, 'AB+', 2019);
INSERT INTO public.player VALUES ('P016', 163.80, 59.50, 'O+', 2022);
INSERT INTO public.player VALUES ('P017', 172.90, 69.80, 'A+', 2020);
INSERT INTO public.player VALUES ('P018', 161.50, 58.80, 'B+', 2021);
INSERT INTO public.player VALUES ('P019', 177.50, 74.00, 'B-', 2022);
INSERT INTO public.player VALUES ('P020', 167.00, 63.10, 'O-', 2019);
INSERT INTO public.player VALUES ('P021', 182.00, 80.50, 'A-', 2021);
INSERT INTO public.player VALUES ('P022', 164.50, 60.00, 'AB-', 2022);
INSERT INTO public.player VALUES ('P023', 173.30, 70.50, 'O+', 2020);
INSERT INTO public.player VALUES ('P024', 160.80, 57.70, 'A+', 2021);
INSERT INTO public.player VALUES ('P025', 184.50, 82.00, 'B+', 2022);
INSERT INTO public.player VALUES ('P026', 169.20, 64.00, 'O-', 2021);
INSERT INTO public.player VALUES ('P027', 171.00, 68.00, 'A-', 2020);
INSERT INTO public.player VALUES ('P028', 162.00, 59.10, 'AB+', 2019);
INSERT INTO public.player VALUES ('P029', 178.90, 76.50, 'B-', 2022);
INSERT INTO public.player VALUES ('P030', 166.00, 61.00, 'O+', 2020);
INSERT INTO public.player VALUES ('P031', 175.00, 72.30, 'A+', 2019);
INSERT INTO public.player VALUES ('P032', 161.00, 58.50, 'B+', 2021);
INSERT INTO public.player VALUES ('P033', 176.50, 73.00, 'O-', 2022);
INSERT INTO public.player VALUES ('P034', 165.00, 60.20, 'A-', 2020);
INSERT INTO public.player VALUES ('P035', 180.00, 78.00, 'AB-', 2021);
INSERT INTO public.player VALUES ('P036', 163.00, 59.00, 'O+', 2022);
INSERT INTO public.player VALUES ('P037', 179.00, 77.80, 'B+', 2019);
INSERT INTO public.player VALUES ('P038', 167.50, 62.50, 'A+', 2022);
INSERT INTO public.player VALUES ('P039', 174.50, 71.90, 'O-', 2020);
INSERT INTO public.player VALUES ('P040', 168.50, 63.50, 'A-', 2021);
INSERT INTO public.player VALUES ('P041', 181.00, 79.00, 'AB+', 2022);
INSERT INTO public.player VALUES ('P042', 164.00, 59.90, 'B-', 2019);
INSERT INTO public.player VALUES ('P043', 170.50, 67.50, 'O+', 2022);
INSERT INTO public.player VALUES ('P044', 169.00, 64.50, 'A+', 2020);
INSERT INTO public.player VALUES ('P045', 177.00, 74.80, 'B+', 2021);
INSERT INTO public.player VALUES ('P046', 161.80, 58.20, 'O-', 2022);
INSERT INTO public.player VALUES ('P047', 172.00, 69.00, 'A-', 2020);
INSERT INTO public.player VALUES ('P048', 165.80, 61.80, 'AB-', 2021);
INSERT INTO public.player VALUES ('P049', 183.50, 81.00, 'O+', 2022);
INSERT INTO public.player VALUES ('P050', 160.50, 57.50, 'B+', 2019);
INSERT INTO public.player VALUES ('P051', 178.50, 76.00, 'A+', 2020);
INSERT INTO public.player VALUES ('P052', 162.80, 59.70, 'O-', 2022);
INSERT INTO public.player VALUES ('P053', 173.00, 70.80, 'A-', 2019);
INSERT INTO public.player VALUES ('P054', 167.80, 63.00, 'AB+', 2021);
INSERT INTO public.player VALUES ('P055', 180.20, 78.50, 'B-', 2022);
INSERT INTO public.player VALUES ('P056', 166.20, 61.20, 'O+', 2020);
INSERT INTO public.player VALUES ('P057', 175.80, 72.80, 'A+', 2021);
INSERT INTO public.player VALUES ('P058', 163.50, 59.30, 'B+', 2022);
INSERT INTO public.player VALUES ('P059', 179.20, 77.20, 'O-', 2020);
INSERT INTO public.player VALUES ('P060', 168.20, 63.30, 'A-', 2022);
INSERT INTO public.player VALUES ('P061', 182.50, 80.00, 'AB-', 2019);
INSERT INTO public.player VALUES ('P062', 164.80, 60.70, 'O+', 2022);
INSERT INTO public.player VALUES ('P063', 171.50, 68.50, 'B+', 2021);
INSERT INTO public.player VALUES ('P064', 160.20, 56.50, 'A+', 2022);
INSERT INTO public.player VALUES ('P065', 176.00, 73.80, 'O-', 2020);
INSERT INTO public.player VALUES ('P066', 169.50, 65.00, 'A-', 2021);
INSERT INTO public.player VALUES ('P067', 181.50, 79.90, 'AB+', 2019);
INSERT INTO public.player VALUES ('P068', 165.20, 60.90, 'B-', 2022);
INSERT INTO public.player VALUES ('P069', 174.20, 71.50, 'O+', 2022);
INSERT INTO public.player VALUES ('P070', 162.20, 58.70, 'A+', 2020);
INSERT INTO public.player VALUES ('P071', 178.20, 75.50, 'B+', 2021);
INSERT INTO public.player VALUES ('P072', 163.20, 59.20, 'O-', 2022);
INSERT INTO public.player VALUES ('P073', 170.80, 67.80, 'A-', 2020);
INSERT INTO public.player VALUES ('P074', 167.20, 62.10, 'AB-', 2021);
INSERT INTO public.player VALUES ('P075', 183.20, 81.80, 'O+', 2019);
INSERT INTO public.player VALUES ('P076', 161.20, 58.60, 'B+', 2021);
INSERT INTO public.player VALUES ('P077', 177.20, 74.30, 'A+', 2022);
INSERT INTO public.player VALUES ('P078', 168.80, 64.20, 'O-', 2020);
INSERT INTO public.player VALUES ('P079', 172.50, 69.30, 'A-', 2021);
INSERT INTO public.player VALUES ('P080', 164.20, 60.40, 'AB+', 2022);
INSERT INTO public.player VALUES ('P081', 184.00, 82.50, 'B-', 2020);
INSERT INTO public.player VALUES ('P082', 159.50, 56.80, 'O+', 2022);
INSERT INTO public.player VALUES ('P083', 175.30, 72.00, 'A+', 2019);
INSERT INTO public.player VALUES ('P084', 165.70, 61.70, 'B+', 2022);
INSERT INTO public.player VALUES ('P085', 178.70, 76.70, 'O-', 2021);
INSERT INTO public.player VALUES ('P086', 162.70, 59.60, 'A-', 2022);
INSERT INTO public.player VALUES ('P087', 180.80, 78.80, 'AB-', 2019);
INSERT INTO public.player VALUES ('P088', 167.70, 62.90, 'O+', 2021);
INSERT INTO public.player VALUES ('P089', 173.80, 71.30, 'B+', 2020);
INSERT INTO public.player VALUES ('P090', 163.70, 59.40, 'A+', 2022);
INSERT INTO public.player VALUES ('P091', 179.70, 77.40, 'O-', 2021);
INSERT INTO public.player VALUES ('P092', 168.70, 63.90, 'A-', 2020);
INSERT INTO public.player VALUES ('P093', 182.70, 80.20, 'AB+', 2022);
INSERT INTO public.player VALUES ('P094', 164.70, 60.60, 'B-', 2021);
INSERT INTO public.player VALUES ('P095', 171.70, 68.70, 'O+', 2020);
INSERT INTO public.player VALUES ('P096', 160.70, 57.30, 'A+', 2022);
INSERT INTO public.player VALUES ('P097', 176.20, 73.20, 'B+', 2019);
INSERT INTO public.player VALUES ('P098', 166.70, 61.40, 'O-', 2022);
INSERT INTO public.player VALUES ('P099', 181.70, 79.20, 'A-', 2021);
INSERT INTO public.player VALUES ('P100', 165.30, 61.10, 'AB-', 2020);
INSERT INTO public.player VALUES ('P101', 175.70, 72.50, 'O+', 2020);
INSERT INTO public.player VALUES ('P102', 162.40, 58.90, 'B+', 2021);
INSERT INTO public.player VALUES ('P103', 178.40, 76.30, 'A+', 2019);
INSERT INTO public.player VALUES ('P104', 166.40, 61.60, 'O-', 2020);
INSERT INTO public.player VALUES ('P105', 180.40, 78.70, 'A-', 2018);
INSERT INTO public.player VALUES ('P106', 163.40, 59.80, 'AB+', 2019);
INSERT INTO public.player VALUES ('P107', 179.40, 77.60, 'B-', 2022);
INSERT INTO public.player VALUES ('P108', 168.40, 63.70, 'O+', 2021);
INSERT INTO public.player VALUES ('P109', 182.40, 80.80, 'A+', 2019);
INSERT INTO public.player VALUES ('P110', 164.40, 60.10, 'B+', 2018);
INSERT INTO public.player VALUES ('P111', 171.20, 68.30, 'O-', 2020);
INSERT INTO public.player VALUES ('P112', 160.40, 57.20, 'A-', 2019);
INSERT INTO public.player VALUES ('P113', 176.70, 73.60, 'AB-', 2021);
INSERT INTO public.player VALUES ('P114', 165.40, 61.30, 'O+', 2023);
INSERT INTO public.player VALUES ('P115', 181.40, 79.70, 'B+', 2022);
INSERT INTO public.player VALUES ('P116', 162.90, 59.50, 'A+', 2020);
INSERT INTO public.player VALUES ('P117', 177.70, 75.00, 'O-', 2019);
INSERT INTO public.player VALUES ('P118', 167.90, 63.20, 'A-', 2018);
INSERT INTO public.player VALUES ('P119', 172.70, 70.00, 'AB+', 2021);
INSERT INTO public.player VALUES ('P120', 166.90, 62.30, 'B-', 2022);
INSERT INTO public.player VALUES ('P121', 184.20, 82.20, 'O+', 2020);
INSERT INTO public.player VALUES ('P122', 161.90, 58.40, 'A+', 2019);
INSERT INTO public.player VALUES ('P123', 175.90, 72.60, 'B+', 2018);
INSERT INTO public.player VALUES ('P124', 163.90, 60.30, 'O-', 2020);
INSERT INTO public.player VALUES ('P125', 178.60, 76.90, 'A-', 2019);
INSERT INTO public.player VALUES ('P126', 168.60, 63.80, 'AB-', 2018);
INSERT INTO public.player VALUES ('P127', 180.60, 78.90, 'O+', 2022);
INSERT INTO public.player VALUES ('P128', 164.60, 60.50, 'B+', 2021);
INSERT INTO public.player VALUES ('P129', 179.60, 77.90, 'A+', 2020);
INSERT INTO public.player VALUES ('P130', 169.60, 64.90, 'O-', 2021);
INSERT INTO public.player VALUES ('P131', 182.60, 80.30, 'A-', 2019);
INSERT INTO public.player VALUES ('P132', 165.60, 61.90, 'AB+', 2023);
INSERT INTO public.player VALUES ('P133', 171.60, 68.80, 'B-', 2020);
INSERT INTO public.player VALUES ('P134', 160.60, 57.80, 'O+', 2022);
INSERT INTO public.player VALUES ('P135', 176.60, 73.40, 'A+', 2021);
INSERT INTO public.player VALUES ('P136', 167.60, 62.70, 'B+', 2019);
INSERT INTO public.player VALUES ('P137', 181.60, 79.40, 'O-', 2018);
INSERT INTO public.player VALUES ('P138', 162.60, 59.40, 'A-', 2020);
INSERT INTO public.player VALUES ('P139', 177.60, 74.70, 'AB-', 2019);
INSERT INTO public.player VALUES ('P140', 163.60, 59.60, 'O+', 2022);
INSERT INTO public.player VALUES ('P141', 183.60, 81.60, 'B+', 2023);
INSERT INTO public.player VALUES ('P142', 168.90, 64.10, 'A+', 2020);
INSERT INTO public.player VALUES ('P143', 174.90, 72.10, 'O-', 2019);
INSERT INTO public.player VALUES ('P144', 164.90, 60.80, 'A-', 2018);
INSERT INTO public.player VALUES ('P145', 179.90, 77.70, 'AB+', 2020);
INSERT INTO public.player VALUES ('P146', 169.90, 65.20, 'B-', 2021);
INSERT INTO public.player VALUES ('P147', 170.20, 67.90, 'O+', 2018);
INSERT INTO public.player VALUES ('P148', 161.70, 58.10, 'A+', 2019);
INSERT INTO public.player VALUES ('P149', 178.10, 75.90, 'B+', 2022);
INSERT INTO public.player VALUES ('P150', 162.10, 58.30, 'O-', 2020);
INSERT INTO public.player VALUES ('P151', 175.40, 71.80, 'A-', 2020);
INSERT INTO public.player VALUES ('P152', 166.80, 62.60, 'AB-', 2021);
INSERT INTO public.player VALUES ('P153', 181.80, 79.60, 'O+', 2019);
INSERT INTO public.player VALUES ('P154', 163.30, 59.10, 'B+', 2020);
INSERT INTO public.player VALUES ('P155', 184.80, 82.80, 'A+', 2018);
INSERT INTO public.player VALUES ('P156', 160.30, 57.60, 'O-', 2019);
INSERT INTO public.player VALUES ('P157', 177.30, 74.50, 'A-', 2021);
INSERT INTO public.player VALUES ('P158', 167.30, 62.40, 'AB+', 2018);
INSERT INTO public.player VALUES ('P159', 172.30, 69.40, 'B-', 2020);
INSERT INTO public.player VALUES ('P160', 161.30, 57.90, 'O+', 2022);
INSERT INTO public.player VALUES ('P161', 176.30, 73.10, 'A+', 2019);
INSERT INTO public.player VALUES ('P162', 165.10, 60.40, 'B+', 2018);
INSERT INTO public.player VALUES ('P163', 180.10, 78.40, 'O-', 2021);
INSERT INTO public.player VALUES ('P164', 164.10, 60.00, 'A-', 2023);
INSERT INTO public.player VALUES ('P165', 179.10, 77.10, 'AB-', 2022);
INSERT INTO public.player VALUES ('P166', 162.00, 58.20, 'O+', 2019);
INSERT INTO public.player VALUES ('P167', 174.10, 71.40, 'B+', 2020);
INSERT INTO public.player VALUES ('P168', 166.10, 61.00, 'A+', 2018);
INSERT INTO public.player VALUES ('P169', 183.10, 81.50, 'O-', 2019);
INSERT INTO public.player VALUES ('P170', 167.10, 62.00, 'A-', 2021);
INSERT INTO public.player VALUES ('P171', 170.10, 67.70, 'AB+', 2018);
INSERT INTO public.player VALUES ('P172', 161.10, 57.70, 'B-', 2019);
INSERT INTO public.player VALUES ('P173', 178.10, 75.30, 'O+', 2020);
INSERT INTO public.player VALUES ('P174', 164.30, 60.00, 'A+', 2022);
INSERT INTO public.player VALUES ('P175', 182.10, 79.80, 'B+', 2023);
INSERT INTO public.player VALUES ('P176', 165.30, 61.10, 'O-', 2018);
INSERT INTO public.player VALUES ('P177', 173.10, 70.40, 'A-', 2019);
INSERT INTO public.player VALUES ('P178', 168.10, 63.60, 'AB-', 2020);
INSERT INTO public.player VALUES ('P179', 177.10, 74.40, 'O+', 2021);
INSERT INTO public.player VALUES ('P180', 162.10, 58.50, 'B+', 2019);
INSERT INTO public.player VALUES ('P181', 180.10, 77.50, 'A+', 2020);
INSERT INTO public.player VALUES ('P182', 160.10, 57.10, 'O-', 2021);
INSERT INTO public.player VALUES ('P183', 176.10, 73.30, 'A-', 2022);
INSERT INTO public.player VALUES ('P184', 169.10, 64.30, 'AB+', 2019);
INSERT INTO public.player VALUES ('P185', 181.10, 78.60, 'B-', 2018);
INSERT INTO public.player VALUES ('P186', 163.10, 59.30, 'O+', 2020);
INSERT INTO public.player VALUES ('P187', 175.10, 72.70, 'A+', 2021);
INSERT INTO public.player VALUES ('P188', 164.90, 60.50, 'B+', 2019);
INSERT INTO public.player VALUES ('P189', 179.80, 77.30, 'O-', 2018);
INSERT INTO public.player VALUES ('P190', 165.90, 61.50, 'A-', 2023);
INSERT INTO public.player VALUES ('P191', 174.80, 71.60, 'AB-', 2019);
INSERT INTO public.player VALUES ('P192', 168.80, 63.40, 'O+', 2021);
INSERT INTO public.player VALUES ('P193', 182.80, 80.60, 'B+', 2020);
INSERT INTO public.player VALUES ('P194', 166.80, 61.70, 'A+', 2018);
INSERT INTO public.player VALUES ('P195', 171.80, 68.60, 'O-', 2022);
INSERT INTO public.player VALUES ('P196', 161.80, 58.00, 'A-', 2020);
INSERT INTO public.player VALUES ('P197', 178.80, 75.60, 'AB+', 2021);
INSERT INTO public.player VALUES ('P198', 167.80, 62.80, 'B-', 2019);
INSERT INTO public.player VALUES ('P199', 180.80, 77.80, 'O+', 2018);
INSERT INTO public.player VALUES ('P200', 162.80, 58.90, 'A+', 2022);


--
-- Data for Name: playerplaysmatch; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playerplaysmatch VALUES ('P001', 'M001');
INSERT INTO public.playerplaysmatch VALUES ('P005', 'M001');
INSERT INTO public.playerplaysmatch VALUES ('P015', 'M001');
INSERT INTO public.playerplaysmatch VALUES ('P027', 'M001');
INSERT INTO public.playerplaysmatch VALUES ('P006', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P011', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P014', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P020', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P003', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P008', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P012', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P017', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P018', 'M004');
INSERT INTO public.playerplaysmatch VALUES ('P024', 'M004');
INSERT INTO public.playerplaysmatch VALUES ('P026', 'M004');
INSERT INTO public.playerplaysmatch VALUES ('P028', 'M004');
INSERT INTO public.playerplaysmatch VALUES ('P004', 'M005');
INSERT INTO public.playerplaysmatch VALUES ('P007', 'M005');
INSERT INTO public.playerplaysmatch VALUES ('P013', 'M005');
INSERT INTO public.playerplaysmatch VALUES ('P025', 'M005');
INSERT INTO public.playerplaysmatch VALUES ('P030', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P031', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P037', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P044', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P034', 'M007');
INSERT INTO public.playerplaysmatch VALUES ('P042', 'M007');
INSERT INTO public.playerplaysmatch VALUES ('P047', 'M007');
INSERT INTO public.playerplaysmatch VALUES ('P053', 'M007');
INSERT INTO public.playerplaysmatch VALUES ('P032', 'M008');
INSERT INTO public.playerplaysmatch VALUES ('P036', 'M008');
INSERT INTO public.playerplaysmatch VALUES ('P040', 'M008');
INSERT INTO public.playerplaysmatch VALUES ('P043', 'M008');
INSERT INTO public.playerplaysmatch VALUES ('P041', 'M009');
INSERT INTO public.playerplaysmatch VALUES ('P045', 'M009');
INSERT INTO public.playerplaysmatch VALUES ('P051', 'M009');
INSERT INTO public.playerplaysmatch VALUES ('P061', 'M009');
INSERT INTO public.playerplaysmatch VALUES ('P048', 'M010');
INSERT INTO public.playerplaysmatch VALUES ('P054', 'M010');
INSERT INTO public.playerplaysmatch VALUES ('P062', 'M010');
INSERT INTO public.playerplaysmatch VALUES ('P066', 'M010');
INSERT INTO public.playerplaysmatch VALUES ('P002', 'M011');
INSERT INTO public.playerplaysmatch VALUES ('P009', 'M011');
INSERT INTO public.playerplaysmatch VALUES ('P019', 'M012');
INSERT INTO public.playerplaysmatch VALUES ('P023', 'M012');
INSERT INTO public.playerplaysmatch VALUES ('P029', 'M013');
INSERT INTO public.playerplaysmatch VALUES ('P035', 'M013');
INSERT INTO public.playerplaysmatch VALUES ('P038', 'M014');
INSERT INTO public.playerplaysmatch VALUES ('P046', 'M014');
INSERT INTO public.playerplaysmatch VALUES ('P056', 'M015');
INSERT INTO public.playerplaysmatch VALUES ('P057', 'M015');
INSERT INTO public.playerplaysmatch VALUES ('P063', 'M015');
INSERT INTO public.playerplaysmatch VALUES ('P065', 'M015');
INSERT INTO public.playerplaysmatch VALUES ('P067', 'M016');
INSERT INTO public.playerplaysmatch VALUES ('P070', 'M016');
INSERT INTO public.playerplaysmatch VALUES ('P071', 'M017');
INSERT INTO public.playerplaysmatch VALUES ('P073', 'M017');
INSERT INTO public.playerplaysmatch VALUES ('P076', 'M018');
INSERT INTO public.playerplaysmatch VALUES ('P077', 'M018');
INSERT INTO public.playerplaysmatch VALUES ('P078', 'M019');
INSERT INTO public.playerplaysmatch VALUES ('P080', 'M019');
INSERT INTO public.playerplaysmatch VALUES ('P081', 'M020');
INSERT INTO public.playerplaysmatch VALUES ('P083', 'M020');
INSERT INTO public.playerplaysmatch VALUES ('P085', 'M020');
INSERT INTO public.playerplaysmatch VALUES ('P087', 'M020');
INSERT INTO public.playerplaysmatch VALUES ('P086', 'M021');
INSERT INTO public.playerplaysmatch VALUES ('P088', 'M021');
INSERT INTO public.playerplaysmatch VALUES ('P091', 'M022');
INSERT INTO public.playerplaysmatch VALUES ('P094', 'M022');
INSERT INTO public.playerplaysmatch VALUES ('P096', 'M023');
INSERT INTO public.playerplaysmatch VALUES ('P098', 'M023');
INSERT INTO public.playerplaysmatch VALUES ('P100', 'M024');
INSERT INTO public.playerplaysmatch VALUES ('P102', 'M024');
INSERT INTO public.playerplaysmatch VALUES ('P104', 'M025');
INSERT INTO public.playerplaysmatch VALUES ('P106', 'M025');
INSERT INTO public.playerplaysmatch VALUES ('P108', 'M025');
INSERT INTO public.playerplaysmatch VALUES ('P109', 'M025');
INSERT INTO public.playerplaysmatch VALUES ('P111', 'M026');
INSERT INTO public.playerplaysmatch VALUES ('P112', 'M026');
INSERT INTO public.playerplaysmatch VALUES ('P113', 'M027');
INSERT INTO public.playerplaysmatch VALUES ('P114', 'M027');
INSERT INTO public.playerplaysmatch VALUES ('P115', 'M028');
INSERT INTO public.playerplaysmatch VALUES ('P116', 'M028');
INSERT INTO public.playerplaysmatch VALUES ('P117', 'M029');
INSERT INTO public.playerplaysmatch VALUES ('P120', 'M029');
INSERT INTO public.playerplaysmatch VALUES ('P122', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P123', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P124', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P126', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P001', 'M031');
INSERT INTO public.playerplaysmatch VALUES ('P002', 'M031');
INSERT INTO public.playerplaysmatch VALUES ('P003', 'M032');
INSERT INTO public.playerplaysmatch VALUES ('P004', 'M032');
INSERT INTO public.playerplaysmatch VALUES ('P005', 'M033');
INSERT INTO public.playerplaysmatch VALUES ('P006', 'M033');
INSERT INTO public.playerplaysmatch VALUES ('P007', 'M034');
INSERT INTO public.playerplaysmatch VALUES ('P008', 'M034');
INSERT INTO public.playerplaysmatch VALUES ('P009', 'M035');
INSERT INTO public.playerplaysmatch VALUES ('P010', 'M035');
INSERT INTO public.playerplaysmatch VALUES ('P011', 'M035');
INSERT INTO public.playerplaysmatch VALUES ('P012', 'M035');
INSERT INTO public.playerplaysmatch VALUES ('P013', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P014', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P015', 'M037');
INSERT INTO public.playerplaysmatch VALUES ('P016', 'M037');
INSERT INTO public.playerplaysmatch VALUES ('P017', 'M038');
INSERT INTO public.playerplaysmatch VALUES ('P018', 'M038');
INSERT INTO public.playerplaysmatch VALUES ('P019', 'M039');
INSERT INTO public.playerplaysmatch VALUES ('P020', 'M039');
INSERT INTO public.playerplaysmatch VALUES ('P021', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P022', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P023', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P024', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P141', 'M041');
INSERT INTO public.playerplaysmatch VALUES ('P149', 'M041');
INSERT INTO public.playerplaysmatch VALUES ('P153', 'M042');
INSERT INTO public.playerplaysmatch VALUES ('P155', 'M042');
INSERT INTO public.playerplaysmatch VALUES ('P158', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P161', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P164', 'M044');
INSERT INTO public.playerplaysmatch VALUES ('P168', 'M044');
INSERT INTO public.playerplaysmatch VALUES ('P172', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P175', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P180', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P184', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P185', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P187', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P190', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P193', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P196', 'M048');
INSERT INTO public.playerplaysmatch VALUES ('P197', 'M048');
INSERT INTO public.playerplaysmatch VALUES ('P198', 'M049');
INSERT INTO public.playerplaysmatch VALUES ('P200', 'M049');
INSERT INTO public.playerplaysmatch VALUES ('P107', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P108', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P110', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P114', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P127', 'M051');
INSERT INTO public.playerplaysmatch VALUES ('P129', 'M051');
INSERT INTO public.playerplaysmatch VALUES ('P132', 'M052');
INSERT INTO public.playerplaysmatch VALUES ('P135', 'M052');
INSERT INTO public.playerplaysmatch VALUES ('P138', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P140', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P144', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P146', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P150', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P152', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P156', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P159', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P163', 'M056');
INSERT INTO public.playerplaysmatch VALUES ('P165', 'M056');
INSERT INTO public.playerplaysmatch VALUES ('P167', 'M057');
INSERT INTO public.playerplaysmatch VALUES ('P170', 'M057');
INSERT INTO public.playerplaysmatch VALUES ('P174', 'M058');
INSERT INTO public.playerplaysmatch VALUES ('P176', 'M058');
INSERT INTO public.playerplaysmatch VALUES ('P179', 'M059');
INSERT INTO public.playerplaysmatch VALUES ('P181', 'M059');
INSERT INTO public.playerplaysmatch VALUES ('P183', 'M060');
INSERT INTO public.playerplaysmatch VALUES ('P186', 'M060');
INSERT INTO public.playerplaysmatch VALUES ('P189', 'M060');
INSERT INTO public.playerplaysmatch VALUES ('P191', 'M060');
INSERT INTO public.playerplaysmatch VALUES ('P001', 'M011');
INSERT INTO public.playerplaysmatch VALUES ('P003', 'M052');
INSERT INTO public.playerplaysmatch VALUES ('P004', 'M016');
INSERT INTO public.playerplaysmatch VALUES ('P006', 'M009');
INSERT INTO public.playerplaysmatch VALUES ('P007', 'M017');
INSERT INTO public.playerplaysmatch VALUES ('P008', 'M024');
INSERT INTO public.playerplaysmatch VALUES ('P010', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P011', 'M022');
INSERT INTO public.playerplaysmatch VALUES ('P012', 'M014');
INSERT INTO public.playerplaysmatch VALUES ('P013', 'M007');
INSERT INTO public.playerplaysmatch VALUES ('P014', 'M026');
INSERT INTO public.playerplaysmatch VALUES ('P016', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P017', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P021', 'M029');
INSERT INTO public.playerplaysmatch VALUES ('P023', 'M051');
INSERT INTO public.playerplaysmatch VALUES ('P025', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P026', 'M018');
INSERT INTO public.playerplaysmatch VALUES ('P027', 'M021');
INSERT INTO public.playerplaysmatch VALUES ('P028', 'M034');
INSERT INTO public.playerplaysmatch VALUES ('P030', 'M023');
INSERT INTO public.playerplaysmatch VALUES ('P032', 'M032');
INSERT INTO public.playerplaysmatch VALUES ('P033', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P035', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P036', 'M044');
INSERT INTO public.playerplaysmatch VALUES ('P037', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P039', 'M026');
INSERT INTO public.playerplaysmatch VALUES ('P040', 'M032');
INSERT INTO public.playerplaysmatch VALUES ('P041', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P043', 'M038');
INSERT INTO public.playerplaysmatch VALUES ('P045', 'M059');
INSERT INTO public.playerplaysmatch VALUES ('P047', 'M027');
INSERT INTO public.playerplaysmatch VALUES ('P049', 'M041');
INSERT INTO public.playerplaysmatch VALUES ('P050', 'M044');
INSERT INTO public.playerplaysmatch VALUES ('P051', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P052', 'M024');
INSERT INTO public.playerplaysmatch VALUES ('P055', 'M019');
INSERT INTO public.playerplaysmatch VALUES ('P056', 'M025');
INSERT INTO public.playerplaysmatch VALUES ('P058', 'M008');
INSERT INTO public.playerplaysmatch VALUES ('P059', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P060', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P062', 'M019');
INSERT INTO public.playerplaysmatch VALUES ('P063', 'M035');
INSERT INTO public.playerplaysmatch VALUES ('P064', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P065', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P068', 'M019');
INSERT INTO public.playerplaysmatch VALUES ('P069', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P070', 'M026');
INSERT INTO public.playerplaysmatch VALUES ('P071', 'M031');
INSERT INTO public.playerplaysmatch VALUES ('P072', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P074', 'M059');
INSERT INTO public.playerplaysmatch VALUES ('P075', 'M021');
INSERT INTO public.playerplaysmatch VALUES ('P076', 'M034');
INSERT INTO public.playerplaysmatch VALUES ('P077', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P079', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P080', 'M004');
INSERT INTO public.playerplaysmatch VALUES ('P081', 'M028');
INSERT INTO public.playerplaysmatch VALUES ('P082', 'M044');
INSERT INTO public.playerplaysmatch VALUES ('P083', 'M048');
INSERT INTO public.playerplaysmatch VALUES ('P084', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P086', 'M022');
INSERT INTO public.playerplaysmatch VALUES ('P087', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P089', 'M037');
INSERT INTO public.playerplaysmatch VALUES ('P090', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P091', 'M058');
INSERT INTO public.playerplaysmatch VALUES ('P092', 'M024');
INSERT INTO public.playerplaysmatch VALUES ('P093', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P095', 'M031');
INSERT INTO public.playerplaysmatch VALUES ('P096', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P097', 'M056');
INSERT INTO public.playerplaysmatch VALUES ('P099', 'M034');
INSERT INTO public.playerplaysmatch VALUES ('P100', 'M047');
INSERT INTO public.playerplaysmatch VALUES ('P101', 'M051');
INSERT INTO public.playerplaysmatch VALUES ('P102', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P103', 'M028');
INSERT INTO public.playerplaysmatch VALUES ('P104', 'M032');
INSERT INTO public.playerplaysmatch VALUES ('P105', 'M048');
INSERT INTO public.playerplaysmatch VALUES ('P106', 'M003');
INSERT INTO public.playerplaysmatch VALUES ('P107', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P108', 'M015');
INSERT INTO public.playerplaysmatch VALUES ('P109', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P110', 'M049');
INSERT INTO public.playerplaysmatch VALUES ('P111', 'M058');
INSERT INTO public.playerplaysmatch VALUES ('P114', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P115', 'M056');
INSERT INTO public.playerplaysmatch VALUES ('P116', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P118', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P119', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P120', 'M014');
INSERT INTO public.playerplaysmatch VALUES ('P121', 'M043');
INSERT INTO public.playerplaysmatch VALUES ('P122', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P123', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P124', 'M027');
INSERT INTO public.playerplaysmatch VALUES ('P125', 'M029');
INSERT INTO public.playerplaysmatch VALUES ('P126', 'M002');
INSERT INTO public.playerplaysmatch VALUES ('P127', 'M037');
INSERT INTO public.playerplaysmatch VALUES ('P128', 'M053');
INSERT INTO public.playerplaysmatch VALUES ('P129', 'M040');
INSERT INTO public.playerplaysmatch VALUES ('P130', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P131', 'M059');
INSERT INTO public.playerplaysmatch VALUES ('P133', 'M030');
INSERT INTO public.playerplaysmatch VALUES ('P134', 'M051');
INSERT INTO public.playerplaysmatch VALUES ('P135', 'M036');
INSERT INTO public.playerplaysmatch VALUES ('P136', 'M042');
INSERT INTO public.playerplaysmatch VALUES ('P137', 'M046');
INSERT INTO public.playerplaysmatch VALUES ('P139', 'M055');
INSERT INTO public.playerplaysmatch VALUES ('P140', 'M054');
INSERT INTO public.playerplaysmatch VALUES ('P141', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P142', 'M049');
INSERT INTO public.playerplaysmatch VALUES ('P143', 'M050');
INSERT INTO public.playerplaysmatch VALUES ('P144', 'M042');
INSERT INTO public.playerplaysmatch VALUES ('P145', 'M049');
INSERT INTO public.playerplaysmatch VALUES ('P146', 'M045');
INSERT INTO public.playerplaysmatch VALUES ('P147', 'M006');
INSERT INTO public.playerplaysmatch VALUES ('P148', 'M027');


--
-- Data for Name: playersport; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playersport VALUES ('P001', 'SP001', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P001', 'SP002', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P005', 'SP002', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P005', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P015', 'SP005', 'Professional', 6);
INSERT INTO public.playersport VALUES ('P015', 'SP001', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P027', 'SP009', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P027', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P045', 'SP010', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P045', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P063', 'SP003', 'Professional', 5);
INSERT INTO public.playersport VALUES ('P063', 'SP004', 'Intermediate', 1);
INSERT INTO public.playersport VALUES ('P081', 'SP004', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P081', 'SP007', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P099', 'SP007', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P121', 'SP008', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P131', 'SP010', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P141', 'SP009', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P008', 'SP006', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P010', 'SP007', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P019', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P022', 'SP008', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P024', 'SP006', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P030', 'SP003', 'Beginner', 2);
INSERT INTO public.playersport VALUES ('P032', 'SP004', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P035', 'SP001', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P038', 'SP006', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P040', 'SP004', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P049', 'SP001', 'Intermediate', 1);
INSERT INTO public.playersport VALUES ('P053', 'SP009', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P056', 'SP003', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P060', 'SP004', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P067', 'SP005', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P070', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P072', 'SP006', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P076', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P079', 'SP001', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P084', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P086', 'SP003', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P089', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P091', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P094', 'SP007', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P098', 'SP003', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P101', 'SP002', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P106', 'SP007', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P111', 'SP005', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P116', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P126', 'SP006', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P136', 'SP003', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P146', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P151', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P156', 'SP003', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P161', 'SP005', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P166', 'SP004', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P171', 'SP001', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P176', 'SP007', 'Advanced', 6);
INSERT INTO public.playersport VALUES ('P181', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P186', 'SP006', 'Beginner', 2);
INSERT INTO public.playersport VALUES ('P191', 'SP009', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P196', 'SP003', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P002', 'SP001', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P002', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P009', 'SP002', 'Professional', 3);
INSERT INTO public.playersport VALUES ('P009', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P016', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P023', 'SP005', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P031', 'SP002', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P039', 'SP009', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P046', 'SP007', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P057', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P065', 'SP005', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P071', 'SP003', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P077', 'SP006', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P085', 'SP004', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P095', 'SP007', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P100', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P107', 'SP009', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P117', 'SP004', 'Intermediate', 5);
INSERT INTO public.playersport VALUES ('P127', 'SP001', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P132', 'SP006', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P137', 'SP005', 'Advanced', 6);
INSERT INTO public.playersport VALUES ('P147', 'SP001', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P152', 'SP007', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P157', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P167', 'SP002', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P172', 'SP008', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P177', 'SP003', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P187', 'SP001', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P197', 'SP009', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P182', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P003', 'SP006', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P003', 'SP008', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P011', 'SP001', 'Professional', 5);
INSERT INTO public.playersport VALUES ('P017', 'SP002', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P025', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P033', 'SP007', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P041', 'SP009', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P047', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P054', 'SP004', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P061', 'SP003', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P069', 'SP010', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P078', 'SP006', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P087', 'SP003', 'Professional', 5);
INSERT INTO public.playersport VALUES ('P103', 'SP004', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P113', 'SP007', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P123', 'SP009', 'Advanced', 6);
INSERT INTO public.playersport VALUES ('P133', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P143', 'SP001', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P148', 'SP006', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P153', 'SP001', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P163', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P168', 'SP004', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P173', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P183', 'SP007', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P193', 'SP010', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P198', 'SP008', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P004', 'SP001', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P004', 'SP005', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P013', 'SP002', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P018', 'SP007', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P026', 'SP003', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P034', 'SP008', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P048', 'SP005', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P055', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P062', 'SP006', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P068', 'SP008', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P075', 'SP001', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P080', 'SP007', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P088', 'SP003', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P093', 'SP009', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P104', 'SP004', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P114', 'SP006', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P119', 'SP007', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P129', 'SP002', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P139', 'SP010', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P144', 'SP006', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P149', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P154', 'SP003', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P164', 'SP004', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P169', 'SP001', 'Intermediate', 5);
INSERT INTO public.playersport VALUES ('P174', 'SP008', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P179', 'SP007', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P189', 'SP002', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P194', 'SP004', 'Advanced', 6);
INSERT INTO public.playersport VALUES ('P199', 'SP005', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P007', 'SP005', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P007', 'SP001', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P014', 'SP006', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P021', 'SP009', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P029', 'SP001', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P037', 'SP005', 'Professional', 5);
INSERT INTO public.playersport VALUES ('P044', 'SP007', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P051', 'SP002', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P059', 'SP006', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P066', 'SP008', 'Beginner', 2);
INSERT INTO public.playersport VALUES ('P073', 'SP003', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P083', 'SP004', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P097', 'SP010', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P105', 'SP002', 'Professional', 6);
INSERT INTO public.playersport VALUES ('P115', 'SP009', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P125', 'SP005', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P135', 'SP001', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P145', 'SP009', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P155', 'SP010', 'Professional', 6);
INSERT INTO public.playersport VALUES ('P165', 'SP001', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P175', 'SP005', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P185', 'SP003', 'Advanced', 6);
INSERT INTO public.playersport VALUES ('P195', 'SP002', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P006', 'SP006', 'Advanced', 3);
INSERT INTO public.playersport VALUES ('P012', 'SP008', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P020', 'SP005', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P028', 'SP009', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P036', 'SP004', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P043', 'SP003', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P050', 'SP007', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P058', 'SP008', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P064', 'SP004', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P074', 'SP002', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P082', 'SP006', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P090', 'SP009', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P096', 'SP007', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P110', 'SP006', 'Advanced', 5);
INSERT INTO public.playersport VALUES ('P120', 'SP005', 'Intermediate', 2);
INSERT INTO public.playersport VALUES ('P130', 'SP008', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P140', 'SP004', 'Advanced', 2);
INSERT INTO public.playersport VALUES ('P150', 'SP003', 'Intermediate', 4);
INSERT INTO public.playersport VALUES ('P160', 'SP006', 'Beginner', 2);
INSERT INTO public.playersport VALUES ('P170', 'SP007', 'Intermediate', 3);
INSERT INTO public.playersport VALUES ('P180', 'SP009', 'Advanced', 4);
INSERT INTO public.playersport VALUES ('P190', 'SP003', 'Beginner', 1);
INSERT INTO public.playersport VALUES ('P200', 'SP004', 'Intermediate', 2);


--
-- Data for Name: playerstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playerstatistics VALUES ('P001', 'M001', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P005', 'M001', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P015', 'M001', 'Goals', 2);
INSERT INTO public.playerstatistics VALUES ('P027', 'M001', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P002', 'M011', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P009', 'M011', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P019', 'M012', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P023', 'M012', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P006', 'M002', 'Runs', 15);
INSERT INTO public.playerstatistics VALUES ('P011', 'M002', 'Runs', 30);
INSERT INTO public.playerstatistics VALUES ('P014', 'M002', 'Runs', 8);
INSERT INTO public.playerstatistics VALUES ('P020', 'M002', 'Runs', 45);
INSERT INTO public.playerstatistics VALUES ('P067', 'M002', 'Wickets', 2);
INSERT INTO public.playerstatistics VALUES ('P067', 'M002', 'Runs', 10);
INSERT INTO public.playerstatistics VALUES ('P091', 'M002', 'Runs', 50);
INSERT INTO public.playerstatistics VALUES ('P111', 'M002', 'Wickets', 3);
INSERT INTO public.playerstatistics VALUES ('P003', 'M003', 'Points', 15);
INSERT INTO public.playerstatistics VALUES ('P008', 'M003', 'Points', 5);
INSERT INTO public.playerstatistics VALUES ('P012', 'M003', 'Points', 20);
INSERT INTO public.playerstatistics VALUES ('P017', 'M003', 'Points', 12);
INSERT INTO public.playerstatistics VALUES ('P019', 'M012', 'Points', 8);
INSERT INTO public.playerstatistics VALUES ('P023', 'M012', 'Points', 18);
INSERT INTO public.playerstatistics VALUES ('P029', 'M013', 'Points', 10);
INSERT INTO public.playerstatistics VALUES ('P035', 'M013', 'Points', 5);
INSERT INTO public.playerstatistics VALUES ('P018', 'M004', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P024', 'M004', 'Points_Scored', 21);
INSERT INTO public.playerstatistics VALUES ('P026', 'M004', 'Points_Scored', 8);
INSERT INTO public.playerstatistics VALUES ('P028', 'M004', 'Points_Scored', 18);
INSERT INTO public.playerstatistics VALUES ('P038', 'M014', 'Points_Scored', 10);
INSERT INTO public.playerstatistics VALUES ('P046', 'M014', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P056', 'M015', 'Points_Scored', 12);
INSERT INTO public.playerstatistics VALUES ('P057', 'M015', 'Points_Scored', 21);
INSERT INTO public.playerstatistics VALUES ('P004', 'M005', 'Games_Won', 4);
INSERT INTO public.playerstatistics VALUES ('P007', 'M005', 'Games_Won', 6);
INSERT INTO public.playerstatistics VALUES ('P013', 'M005', 'Games_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P025', 'M005', 'Games_Won', 3);
INSERT INTO public.playerstatistics VALUES ('P030', 'M006', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P031', 'M006', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P037', 'M006', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P044', 'M006', 'Aces', 3);
INSERT INTO public.playerstatistics VALUES ('P041', 'M024', 'Aces', 4);
INSERT INTO public.playerstatistics VALUES ('P045', 'M024', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P051', 'M024', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P061', 'M024', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P034', 'M007', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P042', 'M007', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P047', 'M007', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P053', 'M007', 'Sets_Won', 0);
INSERT INTO public.playerstatistics VALUES ('P032', 'M008', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P036', 'M008', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P040', 'M008', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P043', 'M008', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P041', 'M009', 'Total_Kg', 220);
INSERT INTO public.playerstatistics VALUES ('P045', 'M009', 'Total_Kg', 230);
INSERT INTO public.playerstatistics VALUES ('P051', 'M009', 'Total_Kg', 180);
INSERT INTO public.playerstatistics VALUES ('P061', 'M009', 'Total_Kg', 210);
INSERT INTO public.playerstatistics VALUES ('P048', 'M010', 'Points_Scored', 20);
INSERT INTO public.playerstatistics VALUES ('P054', 'M010', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P062', 'M010', 'Points_Scored', 10);
INSERT INTO public.playerstatistics VALUES ('P066', 'M010', 'Points_Scored', 18);
INSERT INTO public.playerstatistics VALUES ('P030', 'M006', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P031', 'M006', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P005', 'M012', 'Points', 15);
INSERT INTO public.playerstatistics VALUES ('P006', 'M012', 'Points', 25);
INSERT INTO public.playerstatistics VALUES ('P011', 'M012', 'Points', 18);
INSERT INTO public.playerstatistics VALUES ('P012', 'M012', 'Points', 10);
INSERT INTO public.playerstatistics VALUES ('P029', 'M013', 'Runs', 75);
INSERT INTO public.playerstatistics VALUES ('P035', 'M013', 'Runs', 40);
INSERT INTO public.playerstatistics VALUES ('P042', 'M007', 'Runs', 20);
INSERT INTO public.playerstatistics VALUES ('P047', 'M007', 'Runs', 5);
INSERT INTO public.playerstatistics VALUES ('P063', 'M015', 'Games_Won', 6);
INSERT INTO public.playerstatistics VALUES ('P065', 'M015', 'Games_Won', 5);
INSERT INTO public.playerstatistics VALUES ('P071', 'M015', 'Games_Won', 4);
INSERT INTO public.playerstatistics VALUES ('P073', 'M015', 'Games_Won', 7);
INSERT INTO public.playerstatistics VALUES ('P067', 'M016', 'Aces', 3);
INSERT INTO public.playerstatistics VALUES ('P070', 'M016', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P071', 'M017', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P073', 'M017', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P076', 'M018', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P077', 'M018', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P078', 'M019', 'Sets_Won', 0);
INSERT INTO public.playerstatistics VALUES ('P080', 'M019', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P081', 'M020', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P083', 'M020', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P085', 'M020', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P087', 'M020', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P086', 'M021', 'Total_Kg', 200);
INSERT INTO public.playerstatistics VALUES ('P088', 'M021', 'Total_Kg', 190);
INSERT INTO public.playerstatistics VALUES ('P091', 'M022', 'Total_Kg', 215);
INSERT INTO public.playerstatistics VALUES ('P094', 'M022', 'Total_Kg', 185);
INSERT INTO public.playerstatistics VALUES ('P096', 'M023', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P098', 'M023', 'Points_Scored', 20);
INSERT INTO public.playerstatistics VALUES ('P100', 'M024', 'Points_Scored', 18);
INSERT INTO public.playerstatistics VALUES ('P102', 'M024', 'Points_Scored', 22);
INSERT INTO public.playerstatistics VALUES ('P104', 'M025', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P106', 'M025', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P108', 'M025', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P109', 'M025', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P111', 'M026', 'Runs', 55);
INSERT INTO public.playerstatistics VALUES ('P112', 'M026', 'Runs', 12);
INSERT INTO public.playerstatistics VALUES ('P113', 'M027', 'Runs', 2);
INSERT INTO public.playerstatistics VALUES ('P114', 'M027', 'Runs', 80);
INSERT INTO public.playerstatistics VALUES ('P115', 'M028', 'Points', 5);
INSERT INTO public.playerstatistics VALUES ('P116', 'M028', 'Points', 20);
INSERT INTO public.playerstatistics VALUES ('P117', 'M029', 'Points', 15);
INSERT INTO public.playerstatistics VALUES ('P120', 'M029', 'Points', 8);
INSERT INTO public.playerstatistics VALUES ('P122', 'M030', 'Points_Scored', 21);
INSERT INTO public.playerstatistics VALUES ('P123', 'M030', 'Points_Scored', 10);
INSERT INTO public.playerstatistics VALUES ('P124', 'M030', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P126', 'M030', 'Points_Scored', 20);
INSERT INTO public.playerstatistics VALUES ('P127', 'M031', 'Games_Won', 5);
INSERT INTO public.playerstatistics VALUES ('P129', 'M031', 'Games_Won', 6);
INSERT INTO public.playerstatistics VALUES ('P132', 'M032', 'Games_Won', 3);
INSERT INTO public.playerstatistics VALUES ('P135', 'M032', 'Games_Won', 4);
INSERT INTO public.playerstatistics VALUES ('P138', 'M033', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P140', 'M033', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P144', 'M034', 'Aces', 3);
INSERT INTO public.playerstatistics VALUES ('P146', 'M034', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P150', 'M035', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P152', 'M035', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P156', 'M036', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P159', 'M036', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P163', 'M037', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P165', 'M037', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P167', 'M038', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P170', 'M038', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P174', 'M039', 'Total_Kg', 180);
INSERT INTO public.playerstatistics VALUES ('P176', 'M039', 'Total_Kg', 210);
INSERT INTO public.playerstatistics VALUES ('P179', 'M040', 'Total_Kg', 205);
INSERT INTO public.playerstatistics VALUES ('P181', 'M040', 'Total_Kg', 235);
INSERT INTO public.playerstatistics VALUES ('P183', 'M041', 'Points_Scored', 10);
INSERT INTO public.playerstatistics VALUES ('P186', 'M041', 'Points_Scored', 20);
INSERT INTO public.playerstatistics VALUES ('P189', 'M042', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P191', 'M042', 'Points_Scored', 25);
INSERT INTO public.playerstatistics VALUES ('P001', 'M031', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P002', 'M031', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P003', 'M032', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P004', 'M032', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P005', 'M033', 'Points', 10);
INSERT INTO public.playerstatistics VALUES ('P006', 'M033', 'Points', 15);
INSERT INTO public.playerstatistics VALUES ('P007', 'M034', 'Points', 5);
INSERT INTO public.playerstatistics VALUES ('P008', 'M034', 'Points', 12);
INSERT INTO public.playerstatistics VALUES ('P009', 'M035', 'Runs', 50);
INSERT INTO public.playerstatistics VALUES ('P010', 'M035', 'Runs', 10);
INSERT INTO public.playerstatistics VALUES ('P011', 'M035', 'Runs', 30);
INSERT INTO public.playerstatistics VALUES ('P012', 'M035', 'Runs', 60);
INSERT INTO public.playerstatistics VALUES ('P013', 'M036', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P014', 'M036', 'Points_Scored', 21);
INSERT INTO public.playerstatistics VALUES ('P015', 'M037', 'Points_Scored', 18);
INSERT INTO public.playerstatistics VALUES ('P016', 'M037', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P017', 'M038', 'Games_Won', 5);
INSERT INTO public.playerstatistics VALUES ('P018', 'M038', 'Games_Won', 6);
INSERT INTO public.playerstatistics VALUES ('P019', 'M039', 'Games_Won', 3);
INSERT INTO public.playerstatistics VALUES ('P020', 'M039', 'Games_Won', 4);
INSERT INTO public.playerstatistics VALUES ('P021', 'M040', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P022', 'M040', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P023', 'M040', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P024', 'M040', 'Aces', 3);
INSERT INTO public.playerstatistics VALUES ('P141', 'M041', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P149', 'M041', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P153', 'M042', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P155', 'M042', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P158', 'M043', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P161', 'M043', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P164', 'M044', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P168', 'M044', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P172', 'M045', 'Total_Kg', 230);
INSERT INTO public.playerstatistics VALUES ('P175', 'M045', 'Total_Kg', 240);
INSERT INTO public.playerstatistics VALUES ('P180', 'M045', 'Total_Kg', 190);
INSERT INTO public.playerstatistics VALUES ('P184', 'M045', 'Total_Kg', 210);
INSERT INTO public.playerstatistics VALUES ('P185', 'M046', 'Points_Scored', 12);
INSERT INTO public.playerstatistics VALUES ('P187', 'M046', 'Points_Scored', 23);
INSERT INTO public.playerstatistics VALUES ('P190', 'M047', 'Points_Scored', 18);
INSERT INTO public.playerstatistics VALUES ('P193', 'M047', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P196', 'M048', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P197', 'M048', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P107', 'M050', 'Goals', 1);
INSERT INTO public.playerstatistics VALUES ('P108', 'M050', 'Goals', 0);
INSERT INTO public.playerstatistics VALUES ('P110', 'M050', 'Runs', 5);
INSERT INTO public.playerstatistics VALUES ('P114', 'M050', 'Runs', 15);
INSERT INTO public.playerstatistics VALUES ('P127', 'M051', 'Runs', 30);
INSERT INTO public.playerstatistics VALUES ('P129', 'M051', 'Runs', 55);
INSERT INTO public.playerstatistics VALUES ('P132', 'M052', 'Points', 8);
INSERT INTO public.playerstatistics VALUES ('P135', 'M052', 'Points', 15);
INSERT INTO public.playerstatistics VALUES ('P138', 'M053', 'Points', 20);
INSERT INTO public.playerstatistics VALUES ('P140', 'M053', 'Points', 12);
INSERT INTO public.playerstatistics VALUES ('P144', 'M054', 'Points_Scored', 21);
INSERT INTO public.playerstatistics VALUES ('P146', 'M054', 'Points_Scored', 19);
INSERT INTO public.playerstatistics VALUES ('P150', 'M055', 'Points_Scored', 10);
INSERT INTO public.playerstatistics VALUES ('P152', 'M055', 'Points_Scored', 15);
INSERT INTO public.playerstatistics VALUES ('P156', 'M036', 'Games_Won', 4);
INSERT INTO public.playerstatistics VALUES ('P159', 'M036', 'Games_Won', 6);
INSERT INTO public.playerstatistics VALUES ('P163', 'M056', 'Games_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P165', 'M056', 'Games_Won', 5);
INSERT INTO public.playerstatistics VALUES ('P167', 'M057', 'Aces', 3);
INSERT INTO public.playerstatistics VALUES ('P170', 'M057', 'Aces', 1);
INSERT INTO public.playerstatistics VALUES ('P174', 'M058', 'Aces', 0);
INSERT INTO public.playerstatistics VALUES ('P176', 'M058', 'Aces', 2);
INSERT INTO public.playerstatistics VALUES ('P179', 'M059', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P181', 'M059', 'Sets_Won', 2);
INSERT INTO public.playerstatistics VALUES ('P183', 'M060', 'Sets_Won', 0);
INSERT INTO public.playerstatistics VALUES ('P186', 'M060', 'Sets_Won', 1);
INSERT INTO public.playerstatistics VALUES ('P189', 'M060', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P191', 'M060', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P193', 'M060', 'Win_Loss', 0);
INSERT INTO public.playerstatistics VALUES ('P194', 'M060', 'Win_Loss', 1);
INSERT INTO public.playerstatistics VALUES ('P127', 'M049', 'Total_Kg', 210);
INSERT INTO public.playerstatistics VALUES ('P129', 'M049', 'Total_Kg', 200);
INSERT INTO public.playerstatistics VALUES ('P132', 'M052', 'Total_Kg', 180);
INSERT INTO public.playerstatistics VALUES ('P135', 'M052', 'Total_Kg', 220);
INSERT INTO public.playerstatistics VALUES ('P138', 'M053', 'Points_Scored', 25);
INSERT INTO public.playerstatistics VALUES ('P140', 'M053', 'Points_Scored', 15);


--
-- Data for Name: playerteam; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.playerteam VALUES ('P001', 'T001', '2021-08-15', NULL);
INSERT INTO public.playerteam VALUES ('P005', 'T002', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P008', 'T005', '2021-03-01', '2023-05-30');
INSERT INTO public.playerteam VALUES ('P010', 'T007', '2022-09-10', NULL);
INSERT INTO public.playerteam VALUES ('P015', 'T003', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P019', 'T004', '2022-01-20', NULL);
INSERT INTO public.playerteam VALUES ('P022', 'T008', '2022-05-10', NULL);
INSERT INTO public.playerteam VALUES ('P024', 'T005', '2021-11-05', NULL);
INSERT INTO public.playerteam VALUES ('P027', 'T004', '2020-09-15', NULL);
INSERT INTO public.playerteam VALUES ('P030', 'T006', '2020-10-10', NULL);
INSERT INTO public.playerteam VALUES ('P032', 'T007', '2021-08-20', NULL);
INSERT INTO public.playerteam VALUES ('P035', 'T001', '2021-09-25', NULL);
INSERT INTO public.playerteam VALUES ('P038', 'T005', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P040', 'T007', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P045', 'T010', '2021-08-01', NULL);
INSERT INTO public.playerteam VALUES ('P049', 'T001', '2022-10-10', NULL);
INSERT INTO public.playerteam VALUES ('P053', 'T004', '2020-01-15', NULL);
INSERT INTO public.playerteam VALUES ('P056', 'T006', '2020-12-01', NULL);
INSERT INTO public.playerteam VALUES ('P060', 'T007', '2022-10-05', NULL);
INSERT INTO public.playerteam VALUES ('P063', 'T006', '2021-01-10', NULL);
INSERT INTO public.playerteam VALUES ('P067', 'T003', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P070', 'T009', '2021-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P072', 'T005', '2022-09-10', NULL);
INSERT INTO public.playerteam VALUES ('P076', 'T004', '2021-09-05', NULL);
INSERT INTO public.playerteam VALUES ('P079', 'T001', '2021-10-01', NULL);
INSERT INTO public.playerteam VALUES ('P081', 'T007', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P084', 'T005', '2022-01-15', NULL);
INSERT INTO public.playerteam VALUES ('P086', 'T006', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P089', 'T002', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P091', 'T003', '2021-10-01', NULL);
INSERT INTO public.playerteam VALUES ('P094', 'T008', '2021-09-10', NULL);
INSERT INTO public.playerteam VALUES ('P098', 'T006', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P099', 'T008', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P101', 'T002', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P106', 'T008', '2019-10-15', NULL);
INSERT INTO public.playerteam VALUES ('P111', 'T003', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P116', 'T009', '2020-12-20', NULL);
INSERT INTO public.playerteam VALUES ('P121', 'T009', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P126', 'T005', '2019-10-20', NULL);
INSERT INTO public.playerteam VALUES ('P131', 'T010', '2019-10-01', NULL);
INSERT INTO public.playerteam VALUES ('P136', 'T006', '2019-10-01', NULL);
INSERT INTO public.playerteam VALUES ('P141', 'T004', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P146', 'T005', '2021-10-25', NULL);
INSERT INTO public.playerteam VALUES ('P151', 'T002', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P156', 'T006', '2020-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P161', 'T003', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P166', 'T007', '2020-01-15', NULL);
INSERT INTO public.playerteam VALUES ('P171', 'T001', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P176', 'T008', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P181', 'T002', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P186', 'T005', '2021-03-01', '2022-08-30');
INSERT INTO public.playerteam VALUES ('P191', 'T004', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P196', 'T006', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P002', 'T011', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P009', 'T012', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P016', 'T015', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P023', 'T013', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P031', 'T012', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P039', 'T014', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P046', 'T017', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P052', 'T015', '2022-05-15', NULL);
INSERT INTO public.playerteam VALUES ('P057', 'T015', '2021-01-10', NULL);
INSERT INTO public.playerteam VALUES ('P065', 'T013', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P071', 'T016', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P077', 'T015', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P085', 'T017', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P095', 'T018', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P100', 'T019', '2020-12-01', NULL);
INSERT INTO public.playerteam VALUES ('P107', 'T014', '2022-10-01', NULL);
INSERT INTO public.playerteam VALUES ('P117', 'T017', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P127', 'T011', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P132', 'T015', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P137', 'T013', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P142', 'T015', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P147', 'T011', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P152', 'T018', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P157', 'T013', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P162', 'T015', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P167', 'T012', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P172', 'T019', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P177', 'T016', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P182', 'T015', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P187', 'T011', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P192', 'T018', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P197', 'T014', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P003', 'T025', '2022-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P011', 'T021', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P017', 'T022', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P025', 'T023', '2022-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P033', 'T028', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P041', 'T024', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P047', 'T029', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P054', 'T027', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P061', 'T026', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P069', 'T030', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P078', 'T025', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P087', 'T026', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P092', 'T025', '2020-09-01', '2022-06-30');
INSERT INTO public.playerteam VALUES ('P103', 'T027', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P108', 'T025', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P113', 'T028', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P118', 'T025', '2018-09-01', '2020-08-30');
INSERT INTO public.playerteam VALUES ('P123', 'T024', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P133', 'T022', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P138', 'T025', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P143', 'T021', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P148', 'T025', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P153', 'T021', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P158', 'T027', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P163', 'T024', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P168', 'T027', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P173', 'T022', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P178', 'T025', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P183', 'T028', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P188', 'T025', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P193', 'T030', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P198', 'T029', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P004', 'T031', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P013', 'T032', '2021-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P018', 'T037', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P026', 'T036', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P034', 'T039', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P048', 'T033', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P055', 'T034', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P062', 'T035', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P068', 'T039', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P075', 'T031', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P080', 'T037', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P088', 'T036', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P093', 'T034', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P104', 'T037', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P109', 'T032', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P114', 'T035', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P119', 'T038', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P124', 'T039', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P129', 'T032', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P134', 'T034', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P139', 'T040', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P144', 'T035', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P149', 'T033', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P154', 'T036', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P159', 'T032', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P164', 'T037', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P169', 'T031', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P174', 'T039', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P179', 'T038', '2021-01-01', NULL);
INSERT INTO public.playerteam VALUES ('P184', 'T035', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P189', 'T032', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P194', 'T037', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P199', 'T033', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P007', 'T043', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P014', 'T045', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P021', 'T044', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P029', 'T041', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P037', 'T043', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P044', 'T048', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P051', 'T042', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P059', 'T045', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P066', 'T049', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P073', 'T046', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P083', 'T047', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P090', 'T044', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P097', 'T050', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P105', 'T042', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P115', 'T044', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P125', 'T043', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P135', 'T041', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P145', 'T044', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P155', 'T050', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P165', 'T041', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P175', 'T043', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P185', 'T046', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P195', 'T042', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P006', 'T055', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P012', 'T052', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P020', 'T053', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P028', 'T054', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P036', 'T057', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P043', 'T056', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P050', 'T057', '2019-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P058', 'T059', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P064', 'T057', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P074', 'T052', '2021-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P082', 'T055', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P090', 'T054', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P096', 'T058', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P110', 'T055', '2018-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P120', 'T053', '2022-05-01', NULL);
INSERT INTO public.playerteam VALUES ('P130', 'T059', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P140', 'T057', '2022-03-01', NULL);
INSERT INTO public.playerteam VALUES ('P150', 'T056', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P160', 'T055', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P170', 'T058', '2021-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P180', 'T054', '2020-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P190', 'T056', '2023-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P200', 'T057', '2022-09-01', NULL);
INSERT INTO public.playerteam VALUES ('P001', 'T002', '2020-09-01', '2022-01-15');
INSERT INTO public.playerteam VALUES ('P015', 'T004', '2019-01-10', '2021-08-01');
INSERT INTO public.playerteam VALUES ('P035', 'T003', '2019-10-01', '2023-01-01');
INSERT INTO public.playerteam VALUES ('P053', 'T002', '2019-09-01', '2020-11-30');
INSERT INTO public.playerteam VALUES ('P067', 'T001', '2019-09-01', '2022-09-01');
INSERT INTO public.playerteam VALUES ('P081', 'T009', '2020-03-01', '2023-03-01');
INSERT INTO public.playerteam VALUES ('P106', 'T005', '2019-09-01', '2021-02-14');
INSERT INTO public.playerteam VALUES ('P126', 'T003', '2018-10-01', '2020-10-01');
INSERT INTO public.playerteam VALUES ('P171', 'T005', '2020-01-01', '2022-01-01');
INSERT INTO public.playerteam VALUES ('P186', 'T006', '2020-11-01', '2022-03-10');
INSERT INTO public.playerteam VALUES ('P191', 'T002', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P196', 'T005', '2020-03-01', '2022-05-01');
INSERT INTO public.playerteam VALUES ('P031', 'T011', '2019-09-01', '2021-05-01');
INSERT INTO public.playerteam VALUES ('P057', 'T012', '2020-09-01', '2022-09-01');
INSERT INTO public.playerteam VALUES ('P065', 'T014', '2020-09-01', '2022-01-01');
INSERT INTO public.playerteam VALUES ('P112', 'T016', '2019-10-01', '2021-10-01');
INSERT INTO public.playerteam VALUES ('P147', 'T013', '2018-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P162', 'T018', '2018-09-01', '2020-09-01');
INSERT INTO public.playerteam VALUES ('P177', 'T015', '2019-09-01', '2021-03-01');
INSERT INTO public.playerteam VALUES ('P017', 'T023', '2020-09-01', '2022-02-01');
INSERT INTO public.playerteam VALUES ('P078', 'T026', '2020-03-01', '2022-03-01');
INSERT INTO public.playerteam VALUES ('P113', 'T025', '2021-09-01', '2023-09-01');
INSERT INTO public.playerteam VALUES ('P133', 'T024', '2020-09-01', '2022-05-01');
INSERT INTO public.playerteam VALUES ('P148', 'T027', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P018', 'T035', '2021-09-01', '2023-09-01');
INSERT INTO public.playerteam VALUES ('P034', 'T035', '2020-09-01', '2022-09-01');
INSERT INTO public.playerteam VALUES ('P075', 'T034', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P109', 'T031', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P139', 'T032', '2019-09-01', '2022-09-01');
INSERT INTO public.playerteam VALUES ('P007', 'T042', '2020-09-01', '2022-09-01');
INSERT INTO public.playerteam VALUES ('P037', 'T041', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P051', 'T043', '2020-09-01', '2022-01-01');
INSERT INTO public.playerteam VALUES ('P020', 'T054', '2019-09-01', '2021-09-01');
INSERT INTO public.playerteam VALUES ('P074', 'T055', '2021-03-01', '2023-01-01');


--
-- Data for Name: referee; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.referee VALUES ('R001', 'Ramesh Solanki', '9876500101');
INSERT INTO public.referee VALUES ('R002', 'Vivek Chatterjee', '9876500102');
INSERT INTO public.referee VALUES ('R003', 'Mahesh Patel', '9876500103');
INSERT INTO public.referee VALUES ('R004', 'Snehal Shukla', '9876500104');
INSERT INTO public.referee VALUES ('R005', 'Aarti Deshmukh', '9876500105');
INSERT INTO public.referee VALUES ('R006', 'Viral Shah', '9876500106');
INSERT INTO public.referee VALUES ('R007', 'Dinesh Kumar', '9876500107');
INSERT INTO public.referee VALUES ('R008', 'Pooja Reddy', '9876500108');
INSERT INTO public.referee VALUES ('R009', 'Ankit Sharma', '9876500109');
INSERT INTO public.referee VALUES ('R010', 'Meena Ghosh', '9876500110');


--
-- Data for Name: result; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.result VALUES ('M001', 'T001', 'Win');
INSERT INTO public.result VALUES ('M001', 'T011', 'Loss');
INSERT INTO public.result VALUES ('M002', 'T053', 'Win');
INSERT INTO public.result VALUES ('M002', 'T043', 'Loss');
INSERT INTO public.result VALUES ('M003', 'T022', 'Win');
INSERT INTO public.result VALUES ('M003', 'T042', 'Loss');
INSERT INTO public.result VALUES ('M004', 'T055', 'Win');
INSERT INTO public.result VALUES ('M004', 'T035', 'Loss');
INSERT INTO public.result VALUES ('M005', 'T006', 'Win');
INSERT INTO public.result VALUES ('M005', 'T026', 'Loss');
INSERT INTO public.result VALUES ('M006', 'T004', 'Win');
INSERT INTO public.result VALUES ('M006', 'T014', 'Loss');
INSERT INTO public.result VALUES ('M007', 'T039', 'Win');
INSERT INTO public.result VALUES ('M007', 'T029', 'Loss');
INSERT INTO public.result VALUES ('M008', 'T047', 'Win');
INSERT INTO public.result VALUES ('M008', 'T057', 'Loss');
INSERT INTO public.result VALUES ('M009', 'T010', 'Win');
INSERT INTO public.result VALUES ('M009', 'T040', 'Loss');
INSERT INTO public.result VALUES ('M010', 'T028', 'Win');
INSERT INTO public.result VALUES ('M010', 'T008', 'Loss');
INSERT INTO public.result VALUES ('M011', 'T031', 'Win');
INSERT INTO public.result VALUES ('M011', 'T041', 'Loss');
INSERT INTO public.result VALUES ('M012', 'T012', 'Win');
INSERT INTO public.result VALUES ('M012', 'T052', 'Loss');
INSERT INTO public.result VALUES ('M013', 'T023', 'Loss');
INSERT INTO public.result VALUES ('M013', 'T003', 'Win');
INSERT INTO public.result VALUES ('M014', 'T045', 'Win');
INSERT INTO public.result VALUES ('M014', 'T055', 'Loss');
INSERT INTO public.result VALUES ('M015', 'T036', 'Win');
INSERT INTO public.result VALUES ('M015', 'T016', 'Loss');
INSERT INTO public.result VALUES ('M016', 'T054', 'Win');
INSERT INTO public.result VALUES ('M016', 'T044', 'Loss');
INSERT INTO public.result VALUES ('M017', 'T019', 'Win');
INSERT INTO public.result VALUES ('M017', 'T059', 'Loss');
INSERT INTO public.result VALUES ('M018', 'T027', 'Win');
INSERT INTO public.result VALUES ('M018', 'T007', 'Loss');
INSERT INTO public.result VALUES ('M019', 'T030', 'Win');
INSERT INTO public.result VALUES ('M019', 'T050', 'Loss');
INSERT INTO public.result VALUES ('M020', 'T018', 'Win');
INSERT INTO public.result VALUES ('M020', 'T038', 'Loss');
INSERT INTO public.result VALUES ('M021', 'T001', 'Draw');
INSERT INTO public.result VALUES ('M021', 'T041', 'Draw');
INSERT INTO public.result VALUES ('M022', 'T053', 'Loss');
INSERT INTO public.result VALUES ('M022', 'T023', 'Win');
INSERT INTO public.result VALUES ('M023', 'T012', 'Win');
INSERT INTO public.result VALUES ('M023', 'T032', 'Loss');
INSERT INTO public.result VALUES ('M024', 'T005', 'Win');
INSERT INTO public.result VALUES ('M024', 'T045', 'Loss');
INSERT INTO public.result VALUES ('M025', 'T056', 'Loss');
INSERT INTO public.result VALUES ('M025', 'T016', 'Win');
INSERT INTO public.result VALUES ('M026', 'T024', 'Win');
INSERT INTO public.result VALUES ('M026', 'T054', 'Loss');
INSERT INTO public.result VALUES ('M027', 'T049', 'Win');
INSERT INTO public.result VALUES ('M027', 'T009', 'Loss');
INSERT INTO public.result VALUES ('M028', 'T017', 'Draw');
INSERT INTO public.result VALUES ('M028', 'T037', 'Draw');
INSERT INTO public.result VALUES ('M029', 'T050', 'Loss');
INSERT INTO public.result VALUES ('M029', 'T010', 'Win');
INSERT INTO public.result VALUES ('M030', 'T048', 'Win');
INSERT INTO public.result VALUES ('M030', 'T028', 'Loss');
INSERT INTO public.result VALUES ('M031', 'T001', 'Win');
INSERT INTO public.result VALUES ('M031', 'T031', 'Loss');
INSERT INTO public.result VALUES ('M032', 'T052', 'Win');
INSERT INTO public.result VALUES ('M032', 'T022', 'Loss');
INSERT INTO public.result VALUES ('M033', 'T013', 'Loss');
INSERT INTO public.result VALUES ('M033', 'T043', 'Win');
INSERT INTO public.result VALUES ('M034', 'T055', 'Win');
INSERT INTO public.result VALUES ('M034', 'T015', 'Loss');
INSERT INTO public.result VALUES ('M035', 'T046', 'Win');
INSERT INTO public.result VALUES ('M035', 'T026', 'Loss');
INSERT INTO public.result VALUES ('M036', 'T044', 'Win');
INSERT INTO public.result VALUES ('M036', 'T014', 'Loss');
INSERT INTO public.result VALUES ('M037', 'T009', 'Win');
INSERT INTO public.result VALUES ('M037', 'T039', 'Loss');
INSERT INTO public.result VALUES ('M038', 'T017', 'Loss');
INSERT INTO public.result VALUES ('M038', 'T047', 'Win');
INSERT INTO public.result VALUES ('M039', 'T030', 'Loss');
INSERT INTO public.result VALUES ('M039', 'T050', 'Win');
INSERT INTO public.result VALUES ('M040', 'T008', 'Win');
INSERT INTO public.result VALUES ('M040', 'T048', 'Loss');
INSERT INTO public.result VALUES ('M041', 'T021', 'Draw');
INSERT INTO public.result VALUES ('M041', 'T011', 'Draw');
INSERT INTO public.result VALUES ('M042', 'T003', 'Win');
INSERT INTO public.result VALUES ('M042', 'T043', 'Loss');
INSERT INTO public.result VALUES ('M043', 'T012', 'Win');
INSERT INTO public.result VALUES ('M043', 'T022', 'Loss');
INSERT INTO public.result VALUES ('M044', 'T055', 'Win');
INSERT INTO public.result VALUES ('M044', 'T005', 'Loss');
INSERT INTO public.result VALUES ('M045', 'T036', 'Win');
INSERT INTO public.result VALUES ('M045', 'T056', 'Loss');
INSERT INTO public.result VALUES ('M046', 'T044', 'Win');
INSERT INTO public.result VALUES ('M046', 'T024', 'Loss');
INSERT INTO public.result VALUES ('M047', 'T019', 'Draw');
INSERT INTO public.result VALUES ('M047', 'T059', 'Draw');
INSERT INTO public.result VALUES ('M048', 'T007', 'Win');
INSERT INTO public.result VALUES ('M048', 'T027', 'Loss');
INSERT INTO public.result VALUES ('M049', 'T010', 'Win');
INSERT INTO public.result VALUES ('M049', 'T030', 'Loss');
INSERT INTO public.result VALUES ('M050', 'T018', 'Win');
INSERT INTO public.result VALUES ('M050', 'T048', 'Loss');
INSERT INTO public.result VALUES ('M051', 'T031', 'Loss');
INSERT INTO public.result VALUES ('M051', 'T041', 'Win');
INSERT INTO public.result VALUES ('M052', 'T042', 'Win');
INSERT INTO public.result VALUES ('M052', 'T052', 'Loss');
INSERT INTO public.result VALUES ('M053', 'T003', 'Loss');
INSERT INTO public.result VALUES ('M053', 'T023', 'Win');
INSERT INTO public.result VALUES ('M054', 'T035', 'Win');
INSERT INTO public.result VALUES ('M054', 'T015', 'Loss');
INSERT INTO public.result VALUES ('M055', 'T026', 'Win');
INSERT INTO public.result VALUES ('M055', 'T046', 'Loss');
INSERT INTO public.result VALUES ('M056', 'T004', 'Win');
INSERT INTO public.result VALUES ('M056', 'T054', 'Loss');
INSERT INTO public.result VALUES ('M057', 'T039', 'Win');
INSERT INTO public.result VALUES ('M057', 'T019', 'Loss');
INSERT INTO public.result VALUES ('M058', 'T057', 'Win');
INSERT INTO public.result VALUES ('M058', 'T037', 'Loss');
INSERT INTO public.result VALUES ('M059', 'T010', 'Loss');
INSERT INTO public.result VALUES ('M059', 'T050', 'Win');
INSERT INTO public.result VALUES ('M060', 'T028', 'Win');
INSERT INTO public.result VALUES ('M060', 'T008', 'Loss');


--
-- Data for Name: spectatorpass; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.spectatorpass VALUES ('P205', 'T001', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P211', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P218', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P223', 'T001', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P229', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P238', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P253', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P259', 'T001', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P267', 'T001', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P275', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P283', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P289', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P297', 'T001', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P201', 'T001', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P202', 'T002', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P209', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P215', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P227', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P232', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P239', 'T002', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P247', 'T002', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P256', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P263', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P271', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P287', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P293', 'T002', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P299', 'T002', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P203', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P212', 'T003', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P217', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P222', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P230', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P234', 'T003', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P243', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P250', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P257', 'T003', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P265', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P272', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P284', 'T003', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P290', 'T003', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P204', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P213', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P216', 'T004', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P224', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P231', 'T004', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P235', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P240', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P245', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P251', 'T004', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P260', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P274', 'T004', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P278', 'T004', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P288', 'T004', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P206', 'T005', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P208', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P221', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P225', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P237', 'T005', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P241', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P244', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P252', 'T005', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P262', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P270', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P276', 'T005', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P281', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P295', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P207', 'T005', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P214', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P219', 'T006', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P226', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P228', 'T006', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P236', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P246', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P254', 'T006', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P261', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P268', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P273', 'T006', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P280', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P282', 'T006', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P291', 'T006', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P201', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P203', 'T007', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P209', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P211', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P215', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P217', 'T007', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P227', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P233', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P242', 'T007', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P249', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P258', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P264', 'T007', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P277', 'T007', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P285', 'T007', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P205', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P210', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P214', 'T008', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P220', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P237', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P248', 'T008', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P257', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P266', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P279', 'T008', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P286', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P292', 'T008', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P295', 'T008', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P207', 'T009', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P213', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P221', 'T009', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P225', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P236', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P240', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P253', 'T009', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P260', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P263', 'T009', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P275', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P283', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P294', 'T009', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P202', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P218', 'T010', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P224', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P233', 'T010', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P245', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P251', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P261', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P269', 'T010', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P271', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P280', 'T010', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P297', 'T010', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P204', 'T011', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P206', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P212', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P226', 'T011', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P235', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P241', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P250', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P259', 'T011', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P273', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P281', 'T011', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P290', 'T011', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P208', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P216', 'T012', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P222', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P230', 'T012', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P242', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P249', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P252', 'T012', 'Silver');
INSERT INTO public.spectatorpass VALUES ('P268', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P277', 'T012', 'Regular');
INSERT INTO public.spectatorpass VALUES ('P287', 'T012', 'Gold');
INSERT INTO public.spectatorpass VALUES ('P301', 'T2025', 'gold');


--
-- Data for Name: spectatorviewmatch; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.spectatorviewmatch VALUES ('P205', 'M001');
INSERT INTO public.spectatorviewmatch VALUES ('P211', 'M001');
INSERT INTO public.spectatorviewmatch VALUES ('P259', 'M001');
INSERT INTO public.spectatorviewmatch VALUES ('P205', 'M002');
INSERT INTO public.spectatorviewmatch VALUES ('P218', 'M002');
INSERT INTO public.spectatorviewmatch VALUES ('P267', 'M002');
INSERT INTO public.spectatorviewmatch VALUES ('P223', 'M003');
INSERT INTO public.spectatorviewmatch VALUES ('P253', 'M003');
INSERT INTO public.spectatorviewmatch VALUES ('P283', 'M003');
INSERT INTO public.spectatorviewmatch VALUES ('P229', 'M004');
INSERT INTO public.spectatorviewmatch VALUES ('P238', 'M004');
INSERT INTO public.spectatorviewmatch VALUES ('P297', 'M004');
INSERT INTO public.spectatorviewmatch VALUES ('P201', 'M005');
INSERT INTO public.spectatorviewmatch VALUES ('P205', 'M005');
INSERT INTO public.spectatorviewmatch VALUES ('P259', 'M005');
INSERT INTO public.spectatorviewmatch VALUES ('P202', 'M006');
INSERT INTO public.spectatorviewmatch VALUES ('P209', 'M006');
INSERT INTO public.spectatorviewmatch VALUES ('P215', 'M006');
INSERT INTO public.spectatorviewmatch VALUES ('P227', 'M007');
INSERT INTO public.spectatorviewmatch VALUES ('P232', 'M007');
INSERT INTO public.spectatorviewmatch VALUES ('P239', 'M007');
INSERT INTO public.spectatorviewmatch VALUES ('P247', 'M008');
INSERT INTO public.spectatorviewmatch VALUES ('P256', 'M008');
INSERT INTO public.spectatorviewmatch VALUES ('P263', 'M008');
INSERT INTO public.spectatorviewmatch VALUES ('P271', 'M009');
INSERT INTO public.spectatorviewmatch VALUES ('P287', 'M009');
INSERT INTO public.spectatorviewmatch VALUES ('P293', 'M009');
INSERT INTO public.spectatorviewmatch VALUES ('P299', 'M010');
INSERT INTO public.spectatorviewmatch VALUES ('P202', 'M010');
INSERT INTO public.spectatorviewmatch VALUES ('P215', 'M010');
INSERT INTO public.spectatorviewmatch VALUES ('P203', 'M011');
INSERT INTO public.spectatorviewmatch VALUES ('P212', 'M011');
INSERT INTO public.spectatorviewmatch VALUES ('P217', 'M012');
INSERT INTO public.spectatorviewmatch VALUES ('P222', 'M012');
INSERT INTO public.spectatorviewmatch VALUES ('P230', 'M013');
INSERT INTO public.spectatorviewmatch VALUES ('P234', 'M013');
INSERT INTO public.spectatorviewmatch VALUES ('P243', 'M014');
INSERT INTO public.spectatorviewmatch VALUES ('P250', 'M014');
INSERT INTO public.spectatorviewmatch VALUES ('P257', 'M015');
INSERT INTO public.spectatorviewmatch VALUES ('P265', 'M015');
INSERT INTO public.spectatorviewmatch VALUES ('P272', 'M015');
INSERT INTO public.spectatorviewmatch VALUES ('P284', 'M015');
INSERT INTO public.spectatorviewmatch VALUES ('P204', 'M016');
INSERT INTO public.spectatorviewmatch VALUES ('P213', 'M016');
INSERT INTO public.spectatorviewmatch VALUES ('P216', 'M017');
INSERT INTO public.spectatorviewmatch VALUES ('P224', 'M017');
INSERT INTO public.spectatorviewmatch VALUES ('P231', 'M018');
INSERT INTO public.spectatorviewmatch VALUES ('P235', 'M018');
INSERT INTO public.spectatorviewmatch VALUES ('P240', 'M019');
INSERT INTO public.spectatorviewmatch VALUES ('P245', 'M019');
INSERT INTO public.spectatorviewmatch VALUES ('P251', 'M020');
INSERT INTO public.spectatorviewmatch VALUES ('P260', 'M020');
INSERT INTO public.spectatorviewmatch VALUES ('P274', 'M020');
INSERT INTO public.spectatorviewmatch VALUES ('P278', 'M020');
INSERT INTO public.spectatorviewmatch VALUES ('P206', 'M021');
INSERT INTO public.spectatorviewmatch VALUES ('P208', 'M021');
INSERT INTO public.spectatorviewmatch VALUES ('P221', 'M022');
INSERT INTO public.spectatorviewmatch VALUES ('P225', 'M022');
INSERT INTO public.spectatorviewmatch VALUES ('P237', 'M023');
INSERT INTO public.spectatorviewmatch VALUES ('P241', 'M023');
INSERT INTO public.spectatorviewmatch VALUES ('P244', 'M024');
INSERT INTO public.spectatorviewmatch VALUES ('P252', 'M024');
INSERT INTO public.spectatorviewmatch VALUES ('P262', 'M025');
INSERT INTO public.spectatorviewmatch VALUES ('P270', 'M025');
INSERT INTO public.spectatorviewmatch VALUES ('P276', 'M025');
INSERT INTO public.spectatorviewmatch VALUES ('P281', 'M025');
INSERT INTO public.spectatorviewmatch VALUES ('P214', 'M026');
INSERT INTO public.spectatorviewmatch VALUES ('P219', 'M026');
INSERT INTO public.spectatorviewmatch VALUES ('P226', 'M027');
INSERT INTO public.spectatorviewmatch VALUES ('P228', 'M027');
INSERT INTO public.spectatorviewmatch VALUES ('P236', 'M028');
INSERT INTO public.spectatorviewmatch VALUES ('P246', 'M028');
INSERT INTO public.spectatorviewmatch VALUES ('P254', 'M029');
INSERT INTO public.spectatorviewmatch VALUES ('P261', 'M029');
INSERT INTO public.spectatorviewmatch VALUES ('P268', 'M030');
INSERT INTO public.spectatorviewmatch VALUES ('P273', 'M030');
INSERT INTO public.spectatorviewmatch VALUES ('P280', 'M030');
INSERT INTO public.spectatorviewmatch VALUES ('P282', 'M030');
INSERT INTO public.spectatorviewmatch VALUES ('P201', 'M031');
INSERT INTO public.spectatorviewmatch VALUES ('P203', 'M031');
INSERT INTO public.spectatorviewmatch VALUES ('P209', 'M032');
INSERT INTO public.spectatorviewmatch VALUES ('P211', 'M032');
INSERT INTO public.spectatorviewmatch VALUES ('P215', 'M033');
INSERT INTO public.spectatorviewmatch VALUES ('P217', 'M033');
INSERT INTO public.spectatorviewmatch VALUES ('P227', 'M034');
INSERT INTO public.spectatorviewmatch VALUES ('P233', 'M034');
INSERT INTO public.spectatorviewmatch VALUES ('P242', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P249', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P258', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P264', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P205', 'M036');
INSERT INTO public.spectatorviewmatch VALUES ('P210', 'M036');
INSERT INTO public.spectatorviewmatch VALUES ('P214', 'M037');
INSERT INTO public.spectatorviewmatch VALUES ('P220', 'M037');
INSERT INTO public.spectatorviewmatch VALUES ('P237', 'M038');
INSERT INTO public.spectatorviewmatch VALUES ('P248', 'M038');
INSERT INTO public.spectatorviewmatch VALUES ('P257', 'M039');
INSERT INTO public.spectatorviewmatch VALUES ('P266', 'M039');
INSERT INTO public.spectatorviewmatch VALUES ('P279', 'M040');
INSERT INTO public.spectatorviewmatch VALUES ('P286', 'M040');
INSERT INTO public.spectatorviewmatch VALUES ('P292', 'M040');
INSERT INTO public.spectatorviewmatch VALUES ('P295', 'M040');
INSERT INTO public.spectatorviewmatch VALUES ('P207', 'M041');
INSERT INTO public.spectatorviewmatch VALUES ('P213', 'M041');
INSERT INTO public.spectatorviewmatch VALUES ('P221', 'M042');
INSERT INTO public.spectatorviewmatch VALUES ('P225', 'M042');
INSERT INTO public.spectatorviewmatch VALUES ('P236', 'M043');
INSERT INTO public.spectatorviewmatch VALUES ('P240', 'M043');
INSERT INTO public.spectatorviewmatch VALUES ('P253', 'M044');
INSERT INTO public.spectatorviewmatch VALUES ('P260', 'M044');
INSERT INTO public.spectatorviewmatch VALUES ('P263', 'M045');
INSERT INTO public.spectatorviewmatch VALUES ('P275', 'M045');
INSERT INTO public.spectatorviewmatch VALUES ('P283', 'M045');
INSERT INTO public.spectatorviewmatch VALUES ('P294', 'M045');
INSERT INTO public.spectatorviewmatch VALUES ('P202', 'M046');
INSERT INTO public.spectatorviewmatch VALUES ('P218', 'M046');
INSERT INTO public.spectatorviewmatch VALUES ('P224', 'M047');
INSERT INTO public.spectatorviewmatch VALUES ('P233', 'M047');
INSERT INTO public.spectatorviewmatch VALUES ('P245', 'M048');
INSERT INTO public.spectatorviewmatch VALUES ('P251', 'M048');
INSERT INTO public.spectatorviewmatch VALUES ('P261', 'M049');
INSERT INTO public.spectatorviewmatch VALUES ('P269', 'M049');
INSERT INTO public.spectatorviewmatch VALUES ('P271', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P280', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P297', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P300', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P204', 'M051');
INSERT INTO public.spectatorviewmatch VALUES ('P206', 'M051');
INSERT INTO public.spectatorviewmatch VALUES ('P212', 'M052');
INSERT INTO public.spectatorviewmatch VALUES ('P226', 'M052');
INSERT INTO public.spectatorviewmatch VALUES ('P235', 'M053');
INSERT INTO public.spectatorviewmatch VALUES ('P241', 'M053');
INSERT INTO public.spectatorviewmatch VALUES ('P250', 'M054');
INSERT INTO public.spectatorviewmatch VALUES ('P259', 'M054');
INSERT INTO public.spectatorviewmatch VALUES ('P273', 'M055');
INSERT INTO public.spectatorviewmatch VALUES ('P281', 'M055');
INSERT INTO public.spectatorviewmatch VALUES ('P290', 'M055');
INSERT INTO public.spectatorviewmatch VALUES ('P296', 'M055');
INSERT INTO public.spectatorviewmatch VALUES ('P208', 'M056');
INSERT INTO public.spectatorviewmatch VALUES ('P216', 'M056');
INSERT INTO public.spectatorviewmatch VALUES ('P222', 'M057');
INSERT INTO public.spectatorviewmatch VALUES ('P230', 'M057');
INSERT INTO public.spectatorviewmatch VALUES ('P242', 'M058');
INSERT INTO public.spectatorviewmatch VALUES ('P249', 'M058');
INSERT INTO public.spectatorviewmatch VALUES ('P252', 'M059');
INSERT INTO public.spectatorviewmatch VALUES ('P268', 'M059');
INSERT INTO public.spectatorviewmatch VALUES ('P277', 'M060');
INSERT INTO public.spectatorviewmatch VALUES ('P287', 'M060');
INSERT INTO public.spectatorviewmatch VALUES ('P291', 'M060');
INSERT INTO public.spectatorviewmatch VALUES ('P298', 'M060');
INSERT INTO public.spectatorviewmatch VALUES ('P201', 'M011');
INSERT INTO public.spectatorviewmatch VALUES ('P203', 'M021');
INSERT INTO public.spectatorviewmatch VALUES ('P207', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P210', 'M040');
INSERT INTO public.spectatorviewmatch VALUES ('P215', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P220', 'M055');
INSERT INTO public.spectatorviewmatch VALUES ('P228', 'M007');
INSERT INTO public.spectatorviewmatch VALUES ('P233', 'M014');
INSERT INTO public.spectatorviewmatch VALUES ('P240', 'M023');
INSERT INTO public.spectatorviewmatch VALUES ('P250', 'M032');
INSERT INTO public.spectatorviewmatch VALUES ('P260', 'M043');
INSERT INTO public.spectatorviewmatch VALUES ('P270', 'M051');
INSERT INTO public.spectatorviewmatch VALUES ('P280', 'M001');
INSERT INTO public.spectatorviewmatch VALUES ('P290', 'M010');
INSERT INTO public.spectatorviewmatch VALUES ('P300', 'M015');
INSERT INTO public.spectatorviewmatch VALUES ('P206', 'M026');
INSERT INTO public.spectatorviewmatch VALUES ('P214', 'M035');
INSERT INTO public.spectatorviewmatch VALUES ('P224', 'M044');
INSERT INTO public.spectatorviewmatch VALUES ('P235', 'M054');
INSERT INTO public.spectatorviewmatch VALUES ('P245', 'M005');
INSERT INTO public.spectatorviewmatch VALUES ('P255', 'M018');
INSERT INTO public.spectatorviewmatch VALUES ('P265', 'M028');
INSERT INTO public.spectatorviewmatch VALUES ('P275', 'M038');
INSERT INTO public.spectatorviewmatch VALUES ('P285', 'M048');
INSERT INTO public.spectatorviewmatch VALUES ('P295', 'M058');
INSERT INTO public.spectatorviewmatch VALUES ('P207', 'M004');
INSERT INTO public.spectatorviewmatch VALUES ('P217', 'M013');
INSERT INTO public.spectatorviewmatch VALUES ('P227', 'M022');
INSERT INTO public.spectatorviewmatch VALUES ('P237', 'M031');
INSERT INTO public.spectatorviewmatch VALUES ('P247', 'M041');
INSERT INTO public.spectatorviewmatch VALUES ('P257', 'M050');
INSERT INTO public.spectatorviewmatch VALUES ('P267', 'M059');
INSERT INTO public.spectatorviewmatch VALUES ('P277', 'M008');
INSERT INTO public.spectatorviewmatch VALUES ('P287', 'M017');
INSERT INTO public.spectatorviewmatch VALUES ('P297', 'M027');
INSERT INTO public.spectatorviewmatch VALUES ('P201', 'M038');
INSERT INTO public.spectatorviewmatch VALUES ('P202', 'M049');
INSERT INTO public.spectatorviewmatch VALUES ('P203', 'M059');
INSERT INTO public.spectatorviewmatch VALUES ('P204', 'M009');
INSERT INTO public.spectatorviewmatch VALUES ('P205', 'M019');
INSERT INTO public.spectatorviewmatch VALUES ('P206', 'M029');
INSERT INTO public.spectatorviewmatch VALUES ('P207', 'M039');


--
-- Data for Name: sponsors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sponsors VALUES ('S001', 'Amit Patel', '9824000001', 'Amul India');
INSERT INTO public.sponsors VALUES ('S002', 'Nidhi Shah', '9824000002', 'Zydus Wellness');
INSERT INTO public.sponsors VALUES ('S003', 'Rohan Mehta', '9824000003', 'Adani Sports Foundation');
INSERT INTO public.sponsors VALUES ('S004', 'Sneha Joshi', '9824000004', 'Reliance Foundation');
INSERT INTO public.sponsors VALUES ('S005', 'Vivek Desai', '9824000005', 'Torrent Power');
INSERT INTO public.sponsors VALUES ('S006', 'Jay Thakkar', '9824000006', 'Nirma Ltd');
INSERT INTO public.sponsors VALUES ('S007', 'Siddharth Rana', '9824000007', 'TCS Gandhinagar');
INSERT INTO public.sponsors VALUES ('S008', 'Kavya Trivedi', '9824000008', 'ICICI Foundation');
INSERT INTO public.sponsors VALUES ('S009', 'Dhruv Patel', '9824000009', 'Axis Bank CSR');
INSERT INTO public.sponsors VALUES ('S010', 'Manav Shah', '9824000010', 'Wagh Bakri Tea Group');
INSERT INTO public.sponsors VALUES ('S011', 'Riya Deshmukh', '9824000011', 'Infosys Foundation');
INSERT INTO public.sponsors VALUES ('S012', 'Krish Solanki', '9824000012', 'HDFC CSR');
INSERT INTO public.sponsors VALUES ('S013', 'Mitali Joshi', '9824000013', 'Cadila Pharmaceuticals');
INSERT INTO public.sponsors VALUES ('S014', 'Harsh Vora', '9824000014', 'Gujarat Gas Ltd');
INSERT INTO public.sponsors VALUES ('S015', 'Disha Patel', '9824000015', 'Larsen & Toubro');
INSERT INTO public.sponsors VALUES ('S016', 'Yash Soni', '9824000016', 'ONGC');
INSERT INTO public.sponsors VALUES ('S017', 'Tanya Bansal', '9824000017', 'Parle Agro');
INSERT INTO public.sponsors VALUES ('S018', 'Arjun Kapoor', '9824000018', 'Tata Motors');
INSERT INTO public.sponsors VALUES ('S019', 'Neel Mehta', '9824000019', 'Einfochips');
INSERT INTO public.sponsors VALUES ('S020', 'Pooja Iyer', '9824000020', 'Suzlon Energy');
INSERT INTO public.sponsors VALUES ('S021', 'Priyansh Joshi', '9824000021', 'Amul India');
INSERT INTO public.sponsors VALUES ('S022', 'Rachit Shah', '9824000022', 'Zydus Wellness');
INSERT INTO public.sponsors VALUES ('S023', 'Megha Patel', '9824000023', 'Reliance Foundation');
INSERT INTO public.sponsors VALUES ('S024', 'Sahil Trivedi', '9824000024', 'ICICI Foundation');
INSERT INTO public.sponsors VALUES ('S025', 'Jinal Desai', '9824000025', 'Axis Bank CSR');
INSERT INTO public.sponsors VALUES ('S026', 'Devendra Chauhan', '9824000026', 'HDFC CSR');
INSERT INTO public.sponsors VALUES ('S027', 'Ritika Nair', '9824000027', 'Infosys Foundation');
INSERT INTO public.sponsors VALUES ('S028', 'Aniket Rawal', '9824000028', 'Torrent Power');
INSERT INTO public.sponsors VALUES ('S029', 'Khushi Shah', '9824000029', 'Adani Sports Foundation');
INSERT INTO public.sponsors VALUES ('S030', 'Parth Vyas', '9824000030', 'Wagh Bakri Tea Group');


--
-- Data for Name: sponsorstournament; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sponsorstournament VALUES ('T002', 'S001', 750000.00);
INSERT INTO public.sponsorstournament VALUES ('T002', 'S005', 450000.00);
INSERT INTO public.sponsorstournament VALUES ('T001', 'S002', 300000.00);
INSERT INTO public.sponsorstournament VALUES ('T001', 'S008', 550000.00);
INSERT INTO public.sponsorstournament VALUES ('T004', 'S003', 800000.00);
INSERT INTO public.sponsorstournament VALUES ('T004', 'S009', 400000.00);
INSERT INTO public.sponsorstournament VALUES ('T003', 'S004', 900000.00);
INSERT INTO public.sponsorstournament VALUES ('T003', 'S010', 650000.00);
INSERT INTO public.sponsorstournament VALUES ('T006', 'S006', 500000.00);
INSERT INTO public.sponsorstournament VALUES ('T006', 'S011', 250000.00);
INSERT INTO public.sponsorstournament VALUES ('T005', 'S012', 700000.00);
INSERT INTO public.sponsorstournament VALUES ('T005', 'S013', 450000.00);
INSERT INTO public.sponsorstournament VALUES ('T008', 'S014', 800000.00);
INSERT INTO public.sponsorstournament VALUES ('T008', 'S007', 500000.00);
INSERT INTO public.sponsorstournament VALUES ('T007', 'S015', 600000.00);
INSERT INTO public.sponsorstournament VALUES ('T007', 'S016', 300000.00);
INSERT INTO public.sponsorstournament VALUES ('T010', 'S017', 950000.00);
INSERT INTO public.sponsorstournament VALUES ('T010', 'S018', 400000.00);
INSERT INTO public.sponsorstournament VALUES ('T009', 'S019', 350000.00);
INSERT INTO public.sponsorstournament VALUES ('T009', 'S020', 700000.00);
INSERT INTO public.sponsorstournament VALUES ('T012', 'S021', 850000.00);
INSERT INTO public.sponsorstournament VALUES ('T012', 'S022', 600000.00);
INSERT INTO public.sponsorstournament VALUES ('T011', 'S023', 550000.00);
INSERT INTO public.sponsorstournament VALUES ('T011', 'S024', 300000.00);
INSERT INTO public.sponsorstournament VALUES ('T014', 'S025', 650000.00);
INSERT INTO public.sponsorstournament VALUES ('T014', 'S026', 500000.00);
INSERT INTO public.sponsorstournament VALUES ('T013', 'S027', 700000.00);
INSERT INTO public.sponsorstournament VALUES ('T013', 'S028', 850000.00);
INSERT INTO public.sponsorstournament VALUES ('T010', 'S001', 500000.00);
INSERT INTO public.sponsorstournament VALUES ('T012', 'S001', 520000.00);
INSERT INTO public.sponsorstournament VALUES ('T013', 'S002', 600000.00);
INSERT INTO public.sponsorstournament VALUES ('T008', 'S003', 400000.00);
INSERT INTO public.sponsorstournament VALUES ('T005', 'S009', 350000.00);
INSERT INTO public.sponsorstournament VALUES ('T014', 'S010', 900000.00);


--
-- Data for Name: sportequipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sportequipments VALUES ('SP001', 'E001', 10);
INSERT INTO public.sportequipments VALUES ('SP001', 'E002', 2);
INSERT INTO public.sportequipments VALUES ('SP001', 'E003', 8);
INSERT INTO public.sportequipments VALUES ('SP002', 'E004', 12);
INSERT INTO public.sportequipments VALUES ('SP002', 'E005', 2);
INSERT INTO public.sportequipments VALUES ('SP003', 'E007', 10);
INSERT INTO public.sportequipments VALUES ('SP003', 'E008', 30);
INSERT INTO public.sportequipments VALUES ('SP003', 'E009', 2);
INSERT INTO public.sportequipments VALUES ('SP004', 'E010', 15);
INSERT INTO public.sportequipments VALUES ('SP004', 'E011', 8);
INSERT INTO public.sportequipments VALUES ('SP005', 'E012', 8);
INSERT INTO public.sportequipments VALUES ('SP005', 'E013', 15);
INSERT INTO public.sportequipments VALUES ('SP005', 'E014', 4);
INSERT INTO public.sportequipments VALUES ('SP005', 'E015', 10);
INSERT INTO public.sportequipments VALUES ('SP006', 'E016', 16);
INSERT INTO public.sportequipments VALUES ('SP006', 'E017', 50);
INSERT INTO public.sportequipments VALUES ('SP006', 'E018', 4);
INSERT INTO public.sportequipments VALUES ('SP007', 'E019', 8);
INSERT INTO public.sportequipments VALUES ('SP007', 'E020', 16);
INSERT INTO public.sportequipments VALUES ('SP007', 'E021', 20);
INSERT INTO public.sportequipments VALUES ('SP008', 'E022', 4);
INSERT INTO public.sportequipments VALUES ('SP008', 'E023', 12);
INSERT INTO public.sportequipments VALUES ('SP008', 'E024', 50);
INSERT INTO public.sportequipments VALUES ('SP009', 'E025', 8);
INSERT INTO public.sportequipments VALUES ('SP009', 'E026', 3);
INSERT INTO public.sportequipments VALUES ('SP009', 'E027', 6);
INSERT INTO public.sportequipments VALUES ('SP010', 'E028', 40);
INSERT INTO public.sportequipments VALUES ('SP010', 'E029', 8);
INSERT INTO public.sportequipments VALUES ('SP010', 'E030', 5);


--
-- Data for Name: sportrules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sportrules VALUES ('SP001', 'Football: Two teams of 11 attempt to score by kicking or heading a ball into the opposing team''s goal. Only the goalkeeper can use their hands/arms. The team that scores the most goals wins.');
INSERT INTO public.sportrules VALUES ('SP002', 'Basketball: Two teams of 5 players score points by shooting a ball through a hoop (basket). Players advance the ball by dribbling or passing. Fouls result in free throws or possession loss.');
INSERT INTO public.sportrules VALUES ('SP003', 'Tennis: Players use rackets to hit a ball over a net into the opponent''s court. Scoring follows love, 15, 30, 40, deuce, advantage, and game structure. Matches are played as best-of sets.');
INSERT INTO public.sportrules VALUES ('SP004', 'Chess: Two players move 16 pieces (Pawns, Rooks, Knights, Bishops, Queen, King) on an 8x8 board. The objective is to capture the opponent''s king (checkmate). Each piece has a unique movement pattern.');
INSERT INTO public.sportrules VALUES ('SP005', 'Cricket: Two teams compete in batting and fielding innings. Batters score runs by hitting the ball and running between two wickets. Fielders try to dismiss the batters (e.g., bowled, caught, run out).');
INSERT INTO public.sportrules VALUES ('SP006', 'Badminton: Players use rackets to hit a shuttlecock over a net. A rally ends when the shuttlecock lands within boundaries or is hit illegally. Games are typically played to 21 points.');
INSERT INTO public.sportrules VALUES ('SP007', 'Carrom: Players use a striker to flick carrom men and the queen into four corner pockets. The queen must be covered immediately by a carrom man. The first player to pocket all their men and the covered queen wins.');
INSERT INTO public.sportrules VALUES ('SP008', 'Table Tennis: Two or four players hit a lightweight ball back and forth across a table divided by a net. The ball must bounce once on the receiver''s side. Games are usually played to 11 points.');
INSERT INTO public.sportrules VALUES ('SP009', 'Volleyball: Two teams of six players score points by grounding a ball on the opposing team''s side of the court. Teams can hit the ball a maximum of three times before sending it over the net.');
INSERT INTO public.sportrules VALUES ('SP010', 'Powerlifting: An individual sport testing maximum strength in three lifts: Squat, Bench Press, and Deadlift. The winner is the athlete with the highest total weight lifted across the three successful attempts.');


--
-- Data for Name: sports; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sports VALUES ('SP001', 'Football');
INSERT INTO public.sports VALUES ('SP002', 'Basketball');
INSERT INTO public.sports VALUES ('SP003', 'Tennis');
INSERT INTO public.sports VALUES ('SP004', 'Chess');
INSERT INTO public.sports VALUES ('SP005', 'Cricket');
INSERT INTO public.sports VALUES ('SP006', 'Badminton');
INSERT INTO public.sports VALUES ('SP007', 'Carrom');
INSERT INTO public.sports VALUES ('SP008', 'Table Tennis');
INSERT INTO public.sports VALUES ('SP009', 'Volleyball');
INSERT INTO public.sports VALUES ('SP010', 'Powerlifting');


--
-- Data for Name: sporttype; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sporttype VALUES ('Football', 'Team');
INSERT INTO public.sporttype VALUES ('Basketball', 'Team');
INSERT INTO public.sporttype VALUES ('Tennis', 'Individual');
INSERT INTO public.sporttype VALUES ('Chess', 'Individual');
INSERT INTO public.sporttype VALUES ('Cricket', 'Team');
INSERT INTO public.sporttype VALUES ('Badminton', 'Individual');
INSERT INTO public.sporttype VALUES ('Carrom', 'Individual');
INSERT INTO public.sporttype VALUES ('Table Tennis', 'Individual');
INSERT INTO public.sporttype VALUES ('Volleyball', 'Team');
INSERT INTO public.sporttype VALUES ('Powerlifting', 'Individual');


--
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.team VALUES ('T001', 'SP001', 'DA-IICT Football', 'DA-IICT', 'P001');
INSERT INTO public.team VALUES ('T002', 'SP002', 'DA-IICT Hoopers', 'DA-IICT', 'P005');
INSERT INTO public.team VALUES ('T003', 'SP005', 'DA-IICT Cricket', 'DA-IICT', 'P015');
INSERT INTO public.team VALUES ('T004', 'SP009', 'DA-IICT Volleyball', 'DA-IICT', 'P027');
INSERT INTO public.team VALUES ('T005', 'SP006', 'DA-IICT Smashers (Badminton)', 'DA-IICT', 'P045');
INSERT INTO public.team VALUES ('T006', 'SP003', 'DA-IICT Tennis', 'DA-IICT', 'P063');
INSERT INTO public.team VALUES ('T007', 'SP004', 'DA-IICT Chess', 'DA-IICT', 'P081');
INSERT INTO public.team VALUES ('T008', 'SP007', 'DA-IICT Carrom', 'DA-IICT', 'P099');
INSERT INTO public.team VALUES ('T009', 'SP008', 'DA-IICT Table Tennis', 'DA-IICT', 'P121');
INSERT INTO public.team VALUES ('T010', 'SP010', 'DA-IICT Powerlifting', 'DA-IICT', 'P131');
INSERT INTO public.team VALUES ('T011', 'SP001', 'Nirma Falcons (Football)', 'Nirma University', 'P002');
INSERT INTO public.team VALUES ('T012', 'SP002', 'Nirma Ballers', 'Nirma University', 'P009');
INSERT INTO public.team VALUES ('T013', 'SP005', 'Nirma Titans (Cricket)', 'Nirma University', 'P023');
INSERT INTO public.team VALUES ('T014', 'SP009', 'Nirma Spikers (Volleyball)', 'Nirma University', 'P039');
INSERT INTO public.team VALUES ('T015', 'SP006', 'Nirma Rackets (Badminton)', 'Nirma University', 'P057');
INSERT INTO public.team VALUES ('T016', 'SP003', 'Nirma Tennis', 'Nirma University', 'P071');
INSERT INTO public.team VALUES ('T017', 'SP004', 'Nirma Chess', 'Nirma University', 'P085');
INSERT INTO public.team VALUES ('T018', 'SP007', 'Nirma Carrom', 'Nirma University', 'P095');
INSERT INTO public.team VALUES ('T019', 'SP008', 'Nirma Table Tennis', 'Nirma University', 'P107');
INSERT INTO public.team VALUES ('T020', 'SP010', 'Nirma Powerlifting', 'Nirma University', 'P117');
INSERT INTO public.team VALUES ('T021', 'SP001', 'PDPU Lions (Football)', 'PDPU', 'P011');
INSERT INTO public.team VALUES ('T022', 'SP002', 'PDPU Dunkers (Basketball)', 'PDPU', 'P017');
INSERT INTO public.team VALUES ('T023', 'SP005', 'PDPU Cricket', 'PDPU', 'P025');
INSERT INTO public.team VALUES ('T024', 'SP009', 'PDPU Volleyball', 'PDPU', 'P041');
INSERT INTO public.team VALUES ('T025', 'SP006', 'PDPU Badminton', 'PDPU', 'P061');
INSERT INTO public.team VALUES ('T026', 'SP003', 'PDPU Tennis', 'PDPU', 'P087');
INSERT INTO public.team VALUES ('T027', 'SP004', 'PDPU Chess', 'PDPU', 'P103');
INSERT INTO public.team VALUES ('T028', 'SP007', 'PDPU Carrom', 'PDPU', 'P113');
INSERT INTO public.team VALUES ('T029', 'SP008', 'PDPU Table Tennis', 'PDPU', 'P123');
INSERT INTO public.team VALUES ('T030', 'SP010', 'PDPU Powerlifting', 'PDPU', 'P133');
INSERT INTO public.team VALUES ('T031', 'SP001', 'LDCE Raptors (Football)', 'LDCE', 'P004');
INSERT INTO public.team VALUES ('T032', 'SP002', 'LDCE Pacers (Basketball)', 'LDCE', 'P013');
INSERT INTO public.team VALUES ('T033', 'SP005', 'LDCE Cricket', 'LDCE', 'P048');
INSERT INTO public.team VALUES ('T034', 'SP009', 'LDCE Spikers (Volleyball)', 'LDCE', 'P055');
INSERT INTO public.team VALUES ('T035', 'SP006', 'LDCE Racers (Badminton)', 'LDCE', 'P075');
INSERT INTO public.team VALUES ('T036', 'SP003', 'LDCE Tennis', 'LDCE', 'P088');
INSERT INTO public.team VALUES ('T037', 'SP004', 'LDCE Chess', 'LDCE', 'P104');
INSERT INTO public.team VALUES ('T038', 'SP007', 'LDCE Carrom', 'LDCE', 'P119');
INSERT INTO public.team VALUES ('T039', 'SP008', 'LDCE Table Tennis', 'LDCE', 'P129');
INSERT INTO public.team VALUES ('T040', 'SP010', 'LDCE Powerlifting', 'LDCE', 'P139');
INSERT INTO public.team VALUES ('T041', 'SP001', 'MSU Strikers (Football)', 'MSU Baroda', 'P007');
INSERT INTO public.team VALUES ('T042', 'SP002', 'MSU Baroda Ballers', 'MSU Baroda', 'P021');
INSERT INTO public.team VALUES ('T043', 'SP005', 'MSU Baroda Cricket', 'MSU Baroda', 'P037');
INSERT INTO public.team VALUES ('T044', 'SP009', 'MSU Baroda Volleyball', 'MSU Baroda', 'P051');
INSERT INTO public.team VALUES ('T045', 'SP006', 'MSU Baroda Badminton', 'MSU Baroda', 'P059');
INSERT INTO public.team VALUES ('T046', 'SP003', 'MSU Baroda Tennis', 'MSU Baroda', 'P073');
INSERT INTO public.team VALUES ('T047', 'SP004', 'MSU Baroda Chess', 'MSU Baroda', 'P083');
INSERT INTO public.team VALUES ('T048', 'SP007', 'MSU Baroda Carrom', 'MSU Baroda', 'P097');
INSERT INTO public.team VALUES ('T049', 'SP008', 'MSU Baroda Table Tennis', 'MSU Baroda', 'P105');
INSERT INTO public.team VALUES ('T050', 'SP010', 'MSU Baroda Powerlifting', 'MSU Baroda', 'P115');
INSERT INTO public.team VALUES ('T051', 'SP001', 'IIT Gandhinagar Football', 'IIT Gandhinagar', 'P006');
INSERT INTO public.team VALUES ('T052', 'SP002', 'IIT Gandhinagar Basketball', 'IIT Gandhinagar', 'P012');
INSERT INTO public.team VALUES ('T053', 'SP005', 'IIT Gandhinagar Cricket', 'IIT Gandhinagar', 'P020');
INSERT INTO public.team VALUES ('T054', 'SP009', 'IIT Gandhinagar Volleyball', 'IIT Gandhinagar', 'P028');
INSERT INTO public.team VALUES ('T055', 'SP006', 'IIT Gandhinagar Badminton', 'IIT Gandhinagar', 'P036');
INSERT INTO public.team VALUES ('T056', 'SP003', 'IIT Gandhinagar Tennis', 'IIT Gandhinagar', 'P043');
INSERT INTO public.team VALUES ('T057', 'SP004', 'IIT Gandhinagar Chess', 'IIT Gandhinagar', 'P050');
INSERT INTO public.team VALUES ('T058', 'SP007', 'IIT Gandhinagar Carrom', 'IIT Gandhinagar', 'P058');
INSERT INTO public.team VALUES ('T059', 'SP008', 'IIT Gandhinagar Table Tennis', 'IIT Gandhinagar', 'P064');
INSERT INTO public.team VALUES ('T060', 'SP010', 'IIT Gandhinagar Powerlifting', 'IIT Gandhinagar', 'P074');


--
-- Data for Name: teamcoach; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.teamcoach VALUES ('T001', 'C001', '2021-01-10', NULL);
INSERT INTO public.teamcoach VALUES ('T002', 'C001', '2019-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T031', 'C001', '2020-05-20', '2023-01-01');
INSERT INTO public.teamcoach VALUES ('T012', 'C002', '2020-03-01', NULL);
INSERT INTO public.teamcoach VALUES ('T014', 'C002', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T042', 'C002', '2019-10-01', '2022-05-01');
INSERT INTO public.teamcoach VALUES ('T021', 'C003', '2019-09-01', '2023-09-01');
INSERT INTO public.teamcoach VALUES ('T023', 'C003', '2020-01-15', NULL);
INSERT INTO public.teamcoach VALUES ('T030', 'C003', '2022-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T003', 'C003', '2019-10-01', NULL);
INSERT INTO public.teamcoach VALUES ('T036', 'C004', '2021-05-01', NULL);
INSERT INTO public.teamcoach VALUES ('T038', 'C004', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T039', 'C004', '2020-09-01', '2023-05-01');
INSERT INTO public.teamcoach VALUES ('T056', 'C004', '2022-03-01', NULL);
INSERT INTO public.teamcoach VALUES ('T043', 'C005', '2019-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T044', 'C005', '2020-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T013', 'C005', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T041', 'C005', '2021-03-01', '2023-03-01');
INSERT INTO public.teamcoach VALUES ('T005', 'C006', '2019-10-01', NULL);
INSERT INTO public.teamcoach VALUES ('T006', 'C006', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T035', 'C006', '2022-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T008', 'C006', '2020-09-01', '2022-09-01');
INSERT INTO public.teamcoach VALUES ('T053', 'C007', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T054', 'C007', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T047', 'C007', '2019-09-01', '2022-09-01');
INSERT INTO public.teamcoach VALUES ('T024', 'C007', '2021-05-01', '2023-05-01');
INSERT INTO public.teamcoach VALUES ('T015', 'C008', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T017', 'C008', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T055', 'C008', '2022-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T007', 'C008', '2020-09-01', '2023-09-01');
INSERT INTO public.teamcoach VALUES ('T026', 'C009', '2019-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T028', 'C009', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T029', 'C009', '2020-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T048', 'C009', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T049', 'C009', '2021-01-01', '2023-01-01');
INSERT INTO public.teamcoach VALUES ('T032', 'C010', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T033', 'C010', '2021-05-01', NULL);
INSERT INTO public.teamcoach VALUES ('T052', 'C010', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T016', 'C010', '2020-09-01', '2023-01-01');
INSERT INTO public.teamcoach VALUES ('T010', 'C011', '2020-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T030', 'C011', '2020-09-01', '2022-12-31');
INSERT INTO public.teamcoach VALUES ('T040', 'C011', '2019-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T050', 'C011', '2019-10-01', NULL);
INSERT INTO public.teamcoach VALUES ('T060', 'C011', '2022-05-01', NULL);
INSERT INTO public.teamcoach VALUES ('T011', 'C012', '2020-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T018', 'C012', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T019', 'C012', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T009', 'C012', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T034', 'C013', '2022-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T040', 'C013', '2021-05-01', '2023-05-01');
INSERT INTO public.teamcoach VALUES ('T050', 'C013', '2021-01-01', '2023-01-01');
INSERT INTO public.teamcoach VALUES ('T037', 'C013', '2022-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T057', 'C014', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T058', 'C014', '2022-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T059', 'C014', '2021-09-01', NULL);
INSERT INTO public.teamcoach VALUES ('T045', 'C014', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T046', 'C014', '2020-09-01', '2023-09-01');
INSERT INTO public.teamcoach VALUES ('T022', 'C015', '2021-01-01', NULL);
INSERT INTO public.teamcoach VALUES ('T024', 'C015', '2023-06-01', NULL);
INSERT INTO public.teamcoach VALUES ('T035', 'C015', '2020-09-01', '2021-12-31');
INSERT INTO public.teamcoach VALUES ('T027', 'C015', '2021-05-01', NULL);


--
-- Data for Name: teamplaysmatch; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.teamplaysmatch VALUES ('M001', 'T001');
INSERT INTO public.teamplaysmatch VALUES ('M001', 'T011');
INSERT INTO public.teamplaysmatch VALUES ('M002', 'T053');
INSERT INTO public.teamplaysmatch VALUES ('M002', 'T043');
INSERT INTO public.teamplaysmatch VALUES ('M003', 'T022');
INSERT INTO public.teamplaysmatch VALUES ('M003', 'T042');
INSERT INTO public.teamplaysmatch VALUES ('M004', 'T055');
INSERT INTO public.teamplaysmatch VALUES ('M004', 'T035');
INSERT INTO public.teamplaysmatch VALUES ('M005', 'T006');
INSERT INTO public.teamplaysmatch VALUES ('M005', 'T026');
INSERT INTO public.teamplaysmatch VALUES ('M006', 'T004');
INSERT INTO public.teamplaysmatch VALUES ('M006', 'T014');
INSERT INTO public.teamplaysmatch VALUES ('M007', 'T039');
INSERT INTO public.teamplaysmatch VALUES ('M007', 'T029');
INSERT INTO public.teamplaysmatch VALUES ('M008', 'T047');
INSERT INTO public.teamplaysmatch VALUES ('M008', 'T057');
INSERT INTO public.teamplaysmatch VALUES ('M009', 'T010');
INSERT INTO public.teamplaysmatch VALUES ('M009', 'T040');
INSERT INTO public.teamplaysmatch VALUES ('M010', 'T028');
INSERT INTO public.teamplaysmatch VALUES ('M010', 'T008');
INSERT INTO public.teamplaysmatch VALUES ('M011', 'T031');
INSERT INTO public.teamplaysmatch VALUES ('M011', 'T041');
INSERT INTO public.teamplaysmatch VALUES ('M012', 'T012');
INSERT INTO public.teamplaysmatch VALUES ('M012', 'T052');
INSERT INTO public.teamplaysmatch VALUES ('M013', 'T023');
INSERT INTO public.teamplaysmatch VALUES ('M013', 'T003');
INSERT INTO public.teamplaysmatch VALUES ('M014', 'T045');
INSERT INTO public.teamplaysmatch VALUES ('M014', 'T055');
INSERT INTO public.teamplaysmatch VALUES ('M015', 'T036');
INSERT INTO public.teamplaysmatch VALUES ('M015', 'T016');
INSERT INTO public.teamplaysmatch VALUES ('M016', 'T054');
INSERT INTO public.teamplaysmatch VALUES ('M016', 'T044');
INSERT INTO public.teamplaysmatch VALUES ('M017', 'T019');
INSERT INTO public.teamplaysmatch VALUES ('M017', 'T059');
INSERT INTO public.teamplaysmatch VALUES ('M018', 'T027');
INSERT INTO public.teamplaysmatch VALUES ('M018', 'T007');
INSERT INTO public.teamplaysmatch VALUES ('M019', 'T030');
INSERT INTO public.teamplaysmatch VALUES ('M019', 'T050');
INSERT INTO public.teamplaysmatch VALUES ('M020', 'T018');
INSERT INTO public.teamplaysmatch VALUES ('M020', 'T038');
INSERT INTO public.teamplaysmatch VALUES ('M021', 'T001');
INSERT INTO public.teamplaysmatch VALUES ('M021', 'T041');
INSERT INTO public.teamplaysmatch VALUES ('M022', 'T053');
INSERT INTO public.teamplaysmatch VALUES ('M022', 'T023');
INSERT INTO public.teamplaysmatch VALUES ('M023', 'T012');
INSERT INTO public.teamplaysmatch VALUES ('M023', 'T032');
INSERT INTO public.teamplaysmatch VALUES ('M024', 'T005');
INSERT INTO public.teamplaysmatch VALUES ('M024', 'T045');
INSERT INTO public.teamplaysmatch VALUES ('M025', 'T056');
INSERT INTO public.teamplaysmatch VALUES ('M025', 'T016');
INSERT INTO public.teamplaysmatch VALUES ('M026', 'T024');
INSERT INTO public.teamplaysmatch VALUES ('M026', 'T054');
INSERT INTO public.teamplaysmatch VALUES ('M027', 'T049');
INSERT INTO public.teamplaysmatch VALUES ('M027', 'T009');
INSERT INTO public.teamplaysmatch VALUES ('M028', 'T017');
INSERT INTO public.teamplaysmatch VALUES ('M028', 'T037');
INSERT INTO public.teamplaysmatch VALUES ('M029', 'T050');
INSERT INTO public.teamplaysmatch VALUES ('M029', 'T010');
INSERT INTO public.teamplaysmatch VALUES ('M030', 'T048');
INSERT INTO public.teamplaysmatch VALUES ('M030', 'T028');
INSERT INTO public.teamplaysmatch VALUES ('M031', 'T001');
INSERT INTO public.teamplaysmatch VALUES ('M031', 'T031');
INSERT INTO public.teamplaysmatch VALUES ('M032', 'T052');
INSERT INTO public.teamplaysmatch VALUES ('M032', 'T022');
INSERT INTO public.teamplaysmatch VALUES ('M033', 'T013');
INSERT INTO public.teamplaysmatch VALUES ('M033', 'T043');
INSERT INTO public.teamplaysmatch VALUES ('M034', 'T055');
INSERT INTO public.teamplaysmatch VALUES ('M034', 'T015');
INSERT INTO public.teamplaysmatch VALUES ('M035', 'T046');
INSERT INTO public.teamplaysmatch VALUES ('M035', 'T026');
INSERT INTO public.teamplaysmatch VALUES ('M036', 'T044');
INSERT INTO public.teamplaysmatch VALUES ('M036', 'T014');
INSERT INTO public.teamplaysmatch VALUES ('M037', 'T009');
INSERT INTO public.teamplaysmatch VALUES ('M037', 'T039');
INSERT INTO public.teamplaysmatch VALUES ('M038', 'T017');
INSERT INTO public.teamplaysmatch VALUES ('M038', 'T047');
INSERT INTO public.teamplaysmatch VALUES ('M039', 'T030');
INSERT INTO public.teamplaysmatch VALUES ('M039', 'T050');
INSERT INTO public.teamplaysmatch VALUES ('M040', 'T008');
INSERT INTO public.teamplaysmatch VALUES ('M040', 'T048');
INSERT INTO public.teamplaysmatch VALUES ('M041', 'T021');
INSERT INTO public.teamplaysmatch VALUES ('M041', 'T011');
INSERT INTO public.teamplaysmatch VALUES ('M042', 'T003');
INSERT INTO public.teamplaysmatch VALUES ('M042', 'T043');
INSERT INTO public.teamplaysmatch VALUES ('M043', 'T012');
INSERT INTO public.teamplaysmatch VALUES ('M043', 'T022');
INSERT INTO public.teamplaysmatch VALUES ('M044', 'T055');
INSERT INTO public.teamplaysmatch VALUES ('M044', 'T005');
INSERT INTO public.teamplaysmatch VALUES ('M045', 'T036');
INSERT INTO public.teamplaysmatch VALUES ('M045', 'T056');
INSERT INTO public.teamplaysmatch VALUES ('M046', 'T044');
INSERT INTO public.teamplaysmatch VALUES ('M046', 'T024');
INSERT INTO public.teamplaysmatch VALUES ('M047', 'T019');
INSERT INTO public.teamplaysmatch VALUES ('M047', 'T059');
INSERT INTO public.teamplaysmatch VALUES ('M048', 'T007');
INSERT INTO public.teamplaysmatch VALUES ('M048', 'T027');
INSERT INTO public.teamplaysmatch VALUES ('M049', 'T010');
INSERT INTO public.teamplaysmatch VALUES ('M049', 'T030');
INSERT INTO public.teamplaysmatch VALUES ('M050', 'T018');
INSERT INTO public.teamplaysmatch VALUES ('M050', 'T048');
INSERT INTO public.teamplaysmatch VALUES ('M051', 'T031');
INSERT INTO public.teamplaysmatch VALUES ('M051', 'T041');
INSERT INTO public.teamplaysmatch VALUES ('M052', 'T042');
INSERT INTO public.teamplaysmatch VALUES ('M052', 'T052');
INSERT INTO public.teamplaysmatch VALUES ('M053', 'T003');
INSERT INTO public.teamplaysmatch VALUES ('M053', 'T023');
INSERT INTO public.teamplaysmatch VALUES ('M054', 'T035');
INSERT INTO public.teamplaysmatch VALUES ('M054', 'T015');
INSERT INTO public.teamplaysmatch VALUES ('M055', 'T026');
INSERT INTO public.teamplaysmatch VALUES ('M055', 'T046');
INSERT INTO public.teamplaysmatch VALUES ('M056', 'T004');
INSERT INTO public.teamplaysmatch VALUES ('M056', 'T054');
INSERT INTO public.teamplaysmatch VALUES ('M057', 'T039');
INSERT INTO public.teamplaysmatch VALUES ('M057', 'T019');
INSERT INTO public.teamplaysmatch VALUES ('M058', 'T057');
INSERT INTO public.teamplaysmatch VALUES ('M058', 'T037');
INSERT INTO public.teamplaysmatch VALUES ('M059', 'T010');
INSERT INTO public.teamplaysmatch VALUES ('M059', 'T050');
INSERT INTO public.teamplaysmatch VALUES ('M060', 'T028');
INSERT INTO public.teamplaysmatch VALUES ('M060', 'T008');


--
-- Data for Name: teamstatistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.teamstatistics VALUES ('T001', 'M001', 'Goals', 3);
INSERT INTO public.teamstatistics VALUES ('T011', 'M001', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T053', 'M002', 'Runs', 180);
INSERT INTO public.teamstatistics VALUES ('T043', 'M002', 'Runs', 178);
INSERT INTO public.teamstatistics VALUES ('T022', 'M003', 'Points', 75);
INSERT INTO public.teamstatistics VALUES ('T042', 'M003', 'Points', 68);
INSERT INTO public.teamstatistics VALUES ('T055', 'M004', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T035', 'M004', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T006', 'M005', 'Games_Won', 6);
INSERT INTO public.teamstatistics VALUES ('T026', 'M005', 'Games_Won', 4);
INSERT INTO public.teamstatistics VALUES ('T004', 'M006', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T014', 'M006', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T039', 'M007', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T029', 'M007', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T047', 'M008', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T057', 'M008', 'Win_Loss', 0);
INSERT INTO public.teamstatistics VALUES ('T010', 'M009', 'Total_Weight_Kg', 450);
INSERT INTO public.teamstatistics VALUES ('T040', 'M009', 'Total_Weight_Kg', 430);
INSERT INTO public.teamstatistics VALUES ('T028', 'M010', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T008', 'M010', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T031', 'M011', 'Goals', 2);
INSERT INTO public.teamstatistics VALUES ('T041', 'M011', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T012', 'M012', 'Points', 88);
INSERT INTO public.teamstatistics VALUES ('T052', 'M012', 'Points', 79);
INSERT INTO public.teamstatistics VALUES ('T023', 'M013', 'Runs', 155);
INSERT INTO public.teamstatistics VALUES ('T003', 'M013', 'Runs', 160);
INSERT INTO public.teamstatistics VALUES ('T045', 'M014', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T055', 'M014', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T036', 'M015', 'Games_Won', 7);
INSERT INTO public.teamstatistics VALUES ('T016', 'M015', 'Games_Won', 5);
INSERT INTO public.teamstatistics VALUES ('T054', 'M016', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T044', 'M016', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T019', 'M017', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T059', 'M017', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T027', 'M018', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T007', 'M018', 'Win_Loss', 0);
INSERT INTO public.teamstatistics VALUES ('T030', 'M019', 'Total_Weight_Kg', 480);
INSERT INTO public.teamstatistics VALUES ('T050', 'M019', 'Total_Weight_Kg', 465);
INSERT INTO public.teamstatistics VALUES ('T018', 'M020', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T038', 'M020', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T001', 'M021', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T041', 'M021', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T053', 'M022', 'Runs', 120);
INSERT INTO public.teamstatistics VALUES ('T023', 'M022', 'Runs', 125);
INSERT INTO public.teamstatistics VALUES ('T012', 'M023', 'Points', 90);
INSERT INTO public.teamstatistics VALUES ('T032', 'M023', 'Points', 85);
INSERT INTO public.teamstatistics VALUES ('T005', 'M024', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T045', 'M024', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T056', 'M025', 'Games_Won', 6);
INSERT INTO public.teamstatistics VALUES ('T016', 'M025', 'Games_Won', 7);
INSERT INTO public.teamstatistics VALUES ('T024', 'M026', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T054', 'M026', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T049', 'M027', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T009', 'M027', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T017', 'M028', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T037', 'M028', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T050', 'M029', 'Total_Weight_Kg', 510);
INSERT INTO public.teamstatistics VALUES ('T010', 'M029', 'Total_Weight_Kg', 515);
INSERT INTO public.teamstatistics VALUES ('T048', 'M030', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T028', 'M030', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T001', 'M031', 'Goals', 2);
INSERT INTO public.teamstatistics VALUES ('T031', 'M031', 'Goals', 0);
INSERT INTO public.teamstatistics VALUES ('T052', 'M032', 'Points', 77);
INSERT INTO public.teamstatistics VALUES ('T022', 'M032', 'Points', 75);
INSERT INTO public.teamstatistics VALUES ('T013', 'M033', 'Runs', 135);
INSERT INTO public.teamstatistics VALUES ('T043', 'M033', 'Runs', 140);
INSERT INTO public.teamstatistics VALUES ('T055', 'M034', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T015', 'M034', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T046', 'M035', 'Games_Won', 6);
INSERT INTO public.teamstatistics VALUES ('T026', 'M035', 'Games_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T044', 'M036', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T014', 'M036', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T009', 'M037', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T039', 'M037', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T017', 'M038', 'Win_Loss', 0);
INSERT INTO public.teamstatistics VALUES ('T047', 'M038', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T030', 'M039', 'Total_Weight_Kg', 490);
INSERT INTO public.teamstatistics VALUES ('T050', 'M039', 'Total_Weight_Kg', 495);
INSERT INTO public.teamstatistics VALUES ('T008', 'M040', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T048', 'M040', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T021', 'M041', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T011', 'M041', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T003', 'M042', 'Runs', 190);
INSERT INTO public.teamstatistics VALUES ('T043', 'M042', 'Runs', 188);
INSERT INTO public.teamstatistics VALUES ('T012', 'M043', 'Points', 80);
INSERT INTO public.teamstatistics VALUES ('T022', 'M043', 'Points', 78);
INSERT INTO public.teamstatistics VALUES ('T055', 'M044', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T005', 'M044', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T036', 'M045', 'Games_Won', 6);
INSERT INTO public.teamstatistics VALUES ('T056', 'M045', 'Games_Won', 4);
INSERT INTO public.teamstatistics VALUES ('T044', 'M046', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T024', 'M046', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T019', 'M047', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T059', 'M047', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T007', 'M048', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T027', 'M048', 'Win_Loss', 0);
INSERT INTO public.teamstatistics VALUES ('T010', 'M049', 'Total_Weight_Kg', 500);
INSERT INTO public.teamstatistics VALUES ('T030', 'M049', 'Total_Weight_Kg', 490);
INSERT INTO public.teamstatistics VALUES ('T018', 'M050', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T048', 'M050', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T031', 'M051', 'Goals', 1);
INSERT INTO public.teamstatistics VALUES ('T041', 'M051', 'Goals', 2);
INSERT INTO public.teamstatistics VALUES ('T042', 'M052', 'Points', 95);
INSERT INTO public.teamstatistics VALUES ('T052', 'M052', 'Points', 85);
INSERT INTO public.teamstatistics VALUES ('T003', 'M053', 'Runs', 170);
INSERT INTO public.teamstatistics VALUES ('T023', 'M053', 'Runs', 172);
INSERT INTO public.teamstatistics VALUES ('T035', 'M054', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T015', 'M054', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T026', 'M055', 'Games_Won', 7);
INSERT INTO public.teamstatistics VALUES ('T046', 'M055', 'Games_Won', 5);
INSERT INTO public.teamstatistics VALUES ('T004', 'M056', 'Sets_Won', 3);
INSERT INTO public.teamstatistics VALUES ('T054', 'M056', 'Sets_Won', 0);
INSERT INTO public.teamstatistics VALUES ('T039', 'M057', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T019', 'M057', 'Sets_Won', 1);
INSERT INTO public.teamstatistics VALUES ('T057', 'M058', 'Win_Loss', 1);
INSERT INTO public.teamstatistics VALUES ('T037', 'M058', 'Win_Loss', 0);
INSERT INTO public.teamstatistics VALUES ('T010', 'M059', 'Total_Weight_Kg', 470);
INSERT INTO public.teamstatistics VALUES ('T050', 'M059', 'Total_Weight_Kg', 485);
INSERT INTO public.teamstatistics VALUES ('T028', 'M060', 'Sets_Won', 2);
INSERT INTO public.teamstatistics VALUES ('T008', 'M060', 'Sets_Won', 0);


--
-- Data for Name: tournament; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament VALUES ('T001', 2019, 'spring', '2019-03-10', '2019-03-20');
INSERT INTO public.tournament VALUES ('T002', 2019, 'fall', '2019-09-15', '2019-09-25');
INSERT INTO public.tournament VALUES ('T003', 2020, 'spring', '2020-03-12', '2020-03-22');
INSERT INTO public.tournament VALUES ('T004', 2020, 'fall', '2020-09-18', '2020-09-28');
INSERT INTO public.tournament VALUES ('T005', 2021, 'spring', '2021-03-08', '2021-03-18');
INSERT INTO public.tournament VALUES ('T006', 2021, 'fall', '2021-09-10', '2021-09-20');
INSERT INTO public.tournament VALUES ('T007', 2022, 'spring', '2022-03-05', '2022-03-15');
INSERT INTO public.tournament VALUES ('T008', 2022, 'fall', '2022-09-12', '2022-09-22');
INSERT INTO public.tournament VALUES ('T009', 2023, 'spring', '2023-03-07', '2023-03-17');
INSERT INTO public.tournament VALUES ('T010', 2023, 'fall', '2023-09-09', '2023-09-19');
INSERT INTO public.tournament VALUES ('T011', 2024, 'spring', '2024-03-11', '2024-03-21');
INSERT INTO public.tournament VALUES ('T012', 2024, 'fall', '2024-09-14', '2024-09-24');
INSERT INTO public.tournament VALUES ('T013', 2025, 'spring', '2025-03-09', '2025-03-19');
INSERT INTO public.tournament VALUES ('T014', 2025, 'fall', '2025-09-16', '2025-09-26');
INSERT INTO public.tournament VALUES ('T2025', 2025, 'fall', '2025-11-25', '2025-12-02');


--
-- Data for Name: venue; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.venue VALUES ('V001', 'DA-IICT Main Ground', 'DA-IICT Campus, Gandhinagar');
INSERT INTO public.venue VALUES ('V002', 'Indoor Sports Complex', 'DA-IICT Campus, Gandhinagar');
INSERT INTO public.venue VALUES ('V003', 'Tennis Court', 'Near Hostel Block, DA-IICT');
INSERT INTO public.venue VALUES ('V004', 'Table Tennis Hall', 'Recreation Center, DA-IICT');
INSERT INTO public.venue VALUES ('V005', 'Cricket Ground', 'Sports Complex, DA-IICT');
INSERT INTO public.venue VALUES ('V006', 'Football Ground', 'Main Field, DA-IICT');
INSERT INTO public.venue VALUES ('V007', 'Basketball Court', 'Sports Complex, DA-IICT');
INSERT INTO public.venue VALUES ('V008', 'Volleyball Court', 'Hostel Area, DA-IICT');
INSERT INTO public.venue VALUES ('V009', 'Carrom Room', 'Recreation Center, DA-IICT');
INSERT INTO public.venue VALUES ('V010', 'Chess Room', 'Library Block, DA-IICT');
INSERT INTO public.venue VALUES ('V011', 'Badminton Hall', 'Indoor Sports Complex, DA-IICT');
INSERT INTO public.venue VALUES ('V012', 'Gym Area', 'Fitness Center, DA-IICT');
INSERT INTO public.venue VALUES ('V013', 'Powerlifting Arena', 'Gym Building, DA-IICT');
INSERT INTO public.venue VALUES ('V014', 'Open Lawn', 'Near Canteen Area, DA-IICT');
INSERT INTO public.venue VALUES ('V015', 'Central Auditorium', 'DA-IICT Main Building');


--
-- Name: accommodation accommodation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accommodation
    ADD CONSTRAINT accommodation_pkey PRIMARY KEY (person_id, tournament_id);


--
-- Name: team chk_team_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT chk_team_name UNIQUE (team_name, college_id);


--
-- Name: coach coach_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach
    ADD CONSTRAINT coach_pkey PRIMARY KEY (coach_id);


--
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (company);


--
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (equipment_id);


--
-- Name: match match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (match_id);


--
-- Name: organizer organizer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizer
    ADD CONSTRAINT organizer_pkey PRIMARY KEY (member_id);


--
-- Name: organizetournament organizetournament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizetournament
    ADD CONSTRAINT organizetournament_pkey PRIMARY KEY (tournament_id, member_id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_pkey PRIMARY KEY (player_id);


--
-- Name: playerplaysmatch playerplaysmatch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerplaysmatch
    ADD CONSTRAINT playerplaysmatch_pkey PRIMARY KEY (player_id, match_id);


--
-- Name: playersport playersport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playersport
    ADD CONSTRAINT playersport_pkey PRIMARY KEY (player_id, sport_id);


--
-- Name: playerstatistics playerstatistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerstatistics
    ADD CONSTRAINT playerstatistics_pkey PRIMARY KEY (player_id, match_id, status_name);


--
-- Name: playerteam playerteam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerteam
    ADD CONSTRAINT playerteam_pkey PRIMARY KEY (player_id, team_id);


--
-- Name: referee referee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referee
    ADD CONSTRAINT referee_pkey PRIMARY KEY (referee_id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (match_id, team_id);


--
-- Name: spectatorpass spectatorpass_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorpass
    ADD CONSTRAINT spectatorpass_pkey PRIMARY KEY (spectator_id, tournament_id);


--
-- Name: spectatorviewmatch spectatorviewmatch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorviewmatch
    ADD CONSTRAINT spectatorviewmatch_pkey PRIMARY KEY (spectator_id, match_id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (sponsor_id);


--
-- Name: sponsorstournament sponsorstournament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorstournament
    ADD CONSTRAINT sponsorstournament_pkey PRIMARY KEY (tournament_id, sponsor_id);


--
-- Name: sportequipments sportequipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sportequipments
    ADD CONSTRAINT sportequipments_pkey PRIMARY KEY (sport_id, equipment_id);


--
-- Name: sportrules sportrules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sportrules
    ADD CONSTRAINT sportrules_pkey PRIMARY KEY (sport_id);


--
-- Name: sports sports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT sports_pkey PRIMARY KEY (sport_id);


--
-- Name: sports sports_sport_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sports
    ADD CONSTRAINT sports_sport_name_key UNIQUE (sport_name);


--
-- Name: sporttype sporttype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sporttype
    ADD CONSTRAINT sporttype_pkey PRIMARY KEY (sport_name);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- Name: teamcoach teamcoach_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamcoach
    ADD CONSTRAINT teamcoach_pkey PRIMARY KEY (team_id, coach_id);


--
-- Name: teamplaysmatch teamplaysmatch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamplaysmatch
    ADD CONSTRAINT teamplaysmatch_pkey PRIMARY KEY (match_id, team_id);


--
-- Name: teamstatistics teamstatistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamstatistics
    ADD CONSTRAINT teamstatistics_pkey PRIMARY KEY (team_id, match_id, status_name);


--
-- Name: tournament tournament_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament
    ADD CONSTRAINT tournament_pkey PRIMARY KEY (tournament_id);


--
-- Name: venue venue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venue
    ADD CONSTRAINT venue_pkey PRIMARY KEY (venue_id);


--
-- Name: accommodation accommodation_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accommodation
    ADD CONSTRAINT accommodation_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accommodation accommodation_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accommodation
    ADD CONSTRAINT accommodation_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sponsors fk_company; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsors
    ADD CONSTRAINT fk_company FOREIGN KEY (company) REFERENCES public.company(company) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sponsorstournament fk_sponsor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorstournament
    ADD CONSTRAINT fk_sponsor FOREIGN KEY (sponsor_id) REFERENCES public.sponsors(sponsor_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sporttype fk_sport; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sporttype
    ADD CONSTRAINT fk_sport FOREIGN KEY (sport_name) REFERENCES public.sports(sport_name) ON DELETE CASCADE;


--
-- Name: sponsorstournament fk_tournament; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsorstournament
    ADD CONSTRAINT fk_tournament FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_referee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_referee_id_fkey FOREIGN KEY (referee_id) REFERENCES public.referee(referee_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: match match_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sports(sport_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match match_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venue(venue_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: organizetournament organizetournament_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizetournament
    ADD CONSTRAINT organizetournament_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.organizer(member_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: organizetournament organizetournament_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizetournament
    ADD CONSTRAINT organizetournament_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: player player_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player
    ADD CONSTRAINT player_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerplaysmatch playerplaysmatch_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerplaysmatch
    ADD CONSTRAINT playerplaysmatch_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerplaysmatch playerplaysmatch_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerplaysmatch
    ADD CONSTRAINT playerplaysmatch_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playersport playersport_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playersport
    ADD CONSTRAINT playersport_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playersport playersport_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playersport
    ADD CONSTRAINT playersport_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sports(sport_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerstatistics playerstatistics_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerstatistics
    ADD CONSTRAINT playerstatistics_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerstatistics playerstatistics_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerstatistics
    ADD CONSTRAINT playerstatistics_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerteam playerteam_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerteam
    ADD CONSTRAINT playerteam_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.player(player_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: playerteam playerteam_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playerteam
    ADD CONSTRAINT playerteam_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: result result_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: result result_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spectatorpass spectatorpass_spectator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorpass
    ADD CONSTRAINT spectatorpass_spectator_id_fkey FOREIGN KEY (spectator_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spectatorpass spectatorpass_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorpass
    ADD CONSTRAINT spectatorpass_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournament(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spectatorviewmatch spectatorviewmatch_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorviewmatch
    ADD CONSTRAINT spectatorviewmatch_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spectatorviewmatch spectatorviewmatch_spectator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectatorviewmatch
    ADD CONSTRAINT spectatorviewmatch_spectator_id_fkey FOREIGN KEY (spectator_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sportequipments sportequipments_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sportequipments
    ADD CONSTRAINT sportequipments_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(equipment_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sportequipments sportequipments_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sportequipments
    ADD CONSTRAINT sportequipments_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sports(sport_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sportrules sportrules_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sportrules
    ADD CONSTRAINT sportrules_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sports(sport_id);


--
-- Name: team team_captain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_captain_id_fkey FOREIGN KEY (captain_id) REFERENCES public.player(player_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: team team_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sports(sport_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamcoach teamcoach_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamcoach
    ADD CONSTRAINT teamcoach_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coach(coach_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamcoach teamcoach_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamcoach
    ADD CONSTRAINT teamcoach_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamplaysmatch teamplaysmatch_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamplaysmatch
    ADD CONSTRAINT teamplaysmatch_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamplaysmatch teamplaysmatch_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamplaysmatch
    ADD CONSTRAINT teamplaysmatch_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamstatistics teamstatistics_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamstatistics
    ADD CONSTRAINT teamstatistics_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teamstatistics teamstatistics_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamstatistics
    ADD CONSTRAINT teamstatistics_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict p98kG4dsyjuegM8TQR4aTcFP9QljBjIMnnN9yokrAyRSRK02Q5G7XNsLMCbfOb5

