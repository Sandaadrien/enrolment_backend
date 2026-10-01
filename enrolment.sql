--
-- PostgreSQL database dump
--

\restrict TajHqodeqT7ob1cOz1oGbe26ldPVCSvXmgdxnQ97DG4wSCWcyYtCotoKBI9kAxp

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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
-- Name: contact_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.contact_type AS ENUM (
    'phone',
    'email'
);


ALTER TYPE public.contact_type OWNER TO admin;

--
-- Name: enrolment_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.enrolment_type AS ENUM (
    'NEW',
    'UPDATE',
    'CORRECTION'
);


ALTER TYPE public.enrolment_type OWNER TO admin;

--
-- Name: evidence_strength; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.evidence_strength AS ENUM (
    'SUPERIOR',
    'STRONG',
    'FAIR',
    'WEAK'
);


ALTER TYPE public.evidence_strength OWNER TO admin;

--
-- Name: occupancy_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.occupancy_type AS ENUM (
    'OWNER',
    'TENANT',
    'FAMILY',
    'OTHERS'
);


ALTER TYPE public.occupancy_type OWNER TO admin;

--
-- Name: relationship_type; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.relationship_type AS ENUM (
    'FATHER',
    'MOTHER',
    'SPOUSE'
);


ALTER TYPE public.relationship_type OWNER TO admin;

--
-- Name: sex; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.sex AS ENUM (
    'M',
    'F',
    'Others'
);


ALTER TYPE public.sex OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.address (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_person uuid NOT NULL,
    house_number character varying(255) NOT NULL,
    id_fokontany uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    occupancy_type public.occupancy_type DEFAULT 'OWNER'::public.occupancy_type
);


ALTER TABLE public.address OWNER TO admin;

--
-- Name: agent; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.agent (
    id uuid DEFAULT gen_random_uuid() CONSTRAINT user_id_not_null NOT NULL,
    person_id uuid CONSTRAINT user_person_id_not_null NOT NULL,
    username character varying(255) CONSTRAINT user_username_not_null NOT NULL,
    password_hash character varying(255) CONSTRAINT user_password_hash_not_null NOT NULL,
    id_application_role uuid CONSTRAINT user_id_role_not_null NOT NULL,
    id_centre uuid CONSTRAINT user_id_centre_not_null NOT NULL
);


ALTER TABLE public.agent OWNER TO admin;

--
-- Name: application_role; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.application_role (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.application_role OWNER TO admin;

--
-- Name: centre; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.centre (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(255),
    name character varying(255) NOT NULL,
    id_fokontany uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.centre OWNER TO admin;

--
-- Name: citizen; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.citizen (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    national_unique_id text CONSTRAINT citizen_national_id_not_null NOT NULL
);


ALTER TABLE public.citizen OWNER TO admin;

--
-- Name: COLUMN citizen.national_unique_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.citizen.national_unique_id IS 'Identifiant unique numérique du citoyens';


--
-- Name: citizen_account; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.citizen_account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_citizen uuid NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_empreinte_activated boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.citizen_account OWNER TO admin;

--
-- Name: commune; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.commune (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    district_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.commune OWNER TO admin;

--
-- Name: contact_method; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.contact_method (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL,
    type public.contact_type,
    is_verified boolean DEFAULT false NOT NULL,
    value character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_primary boolean DEFAULT false NOT NULL
);


ALTER TABLE public.contact_method OWNER TO admin;

--
-- Name: country; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.country (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    iso2_code character(2) NOT NULL,
    iso3_code character(3) NOT NULL,
    name character varying(255) NOT NULL,
    nationality_name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.country OWNER TO admin;

--
-- Name: district; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.district (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    region_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.district OWNER TO admin;

--
-- Name: document; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    enrolment_id uuid NOT NULL,
    document_type_id uuid NOT NULL,
    front_file_path text NOT NULL,
    back_file_path text
);


ALTER TABLE public.document OWNER TO admin;

--
-- Name: document_mrz; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_mrz (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    raw_mrz text NOT NULL,
    processed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.document_mrz OWNER TO admin;

--
-- Name: document_ocr_result; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_ocr_result (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    engine_name character varying(255) NOT NULL,
    engine_version character varying(255) NOT NULL,
    extracted_text text NOT NULL,
    confidence_score numeric(5,2) DEFAULT 0 NOT NULL,
    processed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.document_ocr_result OWNER TO admin;

--
-- Name: document_type; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.document_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    evidence_strength public.evidence_strength DEFAULT 'WEAK'::public.evidence_strength NOT NULL,
    requires_mrz boolean DEFAULT false NOT NULL,
    supports_ocr boolean DEFAULT false NOT NULL,
    requires_original boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.document_type OWNER TO admin;

--
-- Name: COLUMN document_type.evidence_strength; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.document_type.evidence_strength IS 'Utile pour savoir le poids d''un documents:
ex:
( Passeport > Permis > CIN > Résidence )';


--
-- Name: enrolment; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.enrolment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid NOT NULL,
    citizen_id uuid NOT NULL,
    application_id text NOT NULL,
    created_offline boolean DEFAULT false NOT NULL,
    sync_status boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    enrolment_type public.enrolment_type DEFAULT 'NEW'::public.enrolment_type NOT NULL
);


ALTER TABLE public.enrolment OWNER TO admin;

--
-- Name: COLUMN enrolment.application_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.enrolment.application_id IS 'Numéro d''enregistrement d''un dossier d''enrolement';


--
-- Name: face_biometrics; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.face_biometrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    enrolment_id uuid NOT NULL,
    image_file_path text NOT NULL,
    model_name character varying(255) NOT NULL,
    model_version character varying(255) NOT NULL,
    embeding text NOT NULL,
    quality_score numeric(5,2) DEFAULT 0 NOT NULL,
    face_detected boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.face_biometrics OWNER TO admin;

--
-- Name: COLUMN face_biometrics.image_file_path; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.face_biometrics.image_file_path IS 'Lien de l''image prise lors de la reconnaissance';


--
-- Name: COLUMN face_biometrics.quality_score; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.face_biometrics.quality_score IS 'score de l''embedding de l''image du visage';


--
-- Name: family_relationships; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.family_relationships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    citizen_id uuid CONSTRAINT family_relationships_person_id_not_null NOT NULL,
    related_person_id uuid,
    related_person_name character varying(255),
    relationship_type public.relationship_type NOT NULL
);


ALTER TABLE public.family_relationships OWNER TO admin;

--
-- Name: fokontany; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.fokontany (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    commune_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.fokontany OWNER TO admin;

--
-- Name: password_reset_otp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_otp (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid NOT NULL,
    otp_hash character varying(255) NOT NULL,
    expires_at timestamp(6) with time zone NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    used_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.password_reset_otp OWNER TO postgres;

--
-- Name: password_reset_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_token (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp(6) with time zone NOT NULL,
    used_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.password_reset_token OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.person (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    first_name character varying(255),
    last_name character varying(255) NOT NULL,
    date_of_birth date,
    birth_place character varying(255),
    id_country_of_birth uuid NOT NULL,
    sex public.sex NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    date_of_death date
);


ALTER TABLE public.person OWNER TO admin;

--
-- Name: refresh_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_token (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agent_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp(6) with time zone NOT NULL,
    revoked_at timestamp(6) with time zone,
    created_at timestamp(6) with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.refresh_token OWNER TO postgres;

--
-- Name: region; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.region (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    country_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.region OWNER TO admin;

--
-- Data for Name: address; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.address (id, id_person, house_number, id_fokontany, created_at, updated_at, occupancy_type) FROM stdin;
8741c088-07b3-4067-9187-bec8006d2872	9fe3017f-95f8-4f26-a4c8-933da500ba69	12B	33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	2026-09-08 10:08:12.743+03	\N	OWNER
dfa027e4-96e0-45c4-a8e1-7518322dde5f	9bb2173d-fb11-4fee-80fd-94ad22e4d17f	12B	33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	2026-09-08 15:04:51.956+03	\N	OWNER
e96ef502-7b9b-4472-9390-5c05cb9445c6	944fdb6e-1783-4221-9c60-870699b1f059	12B	33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	2026-09-08 15:07:10.486+03	\N	OWNER
1dc57443-b8b0-4da9-a3ed-9e3c99f15d86	12e12741-5167-4052-863c-6ee3074aa7b0	12B	33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	2026-09-08 15:09:17.053+03	\N	OWNER
0e993e33-43fd-4cbe-a279-e1f7953d762c	c7e1b089-dedd-4586-b91a-88297d4df72b	12B	33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	2026-09-08 18:19:13.29+03	\N	OWNER
\.


--
-- Data for Name: agent; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.agent (id, person_id, username, password_hash, id_application_role, id_centre) FROM stdin;
3d6a9c16-4ed0-4a4c-aaa6-054e3da4a0c4	6ee6518c-99ea-4594-ac71-fd2df5d5d975	agent.ankadikely.01	$2b$12$GzYK6z7J72lC0C1xs09NoeyQVHsAiCdZtP9.BJZK4cAUEF1tD7J46	bf1b7ab3-87e3-495a-bbbc-fdc70e15bdeb	62505d4e-63d7-4889-83f5-64e2e95950ff
8d1b0bbd-63ba-44dc-9719-4fccc4499ad5	3b26d0e2-c051-4ab0-9967-1803b91a367d	agent.ivandry.01	$2b$12$GzYK6z7J72lC0C1xs09NoeyQVHsAiCdZtP9.BJZK4cAUEF1tD7J46	bf1b7ab3-87e3-495a-bbbc-fdc70e15bdeb	552deb5f-80cc-4b4c-af86-e733c0cf2842
4257f270-d0f4-4ad4-a530-32612cb7113e	e702fb40-606b-44b6-88b6-cd30d2917fea	agent.ilafy.01	$2b$12$kvmn4ek6YCIX19mNoIvb2uT2AEqu0Cxm0fiEvUWagdu2ygMWIZXmS	bf1b7ab3-87e3-495a-bbbc-fdc70e15bdeb	4b4704e7-11f8-4499-9d90-ca02213571e0
f47b953f-49ae-4c84-a8d7-38acc109cc8d	ded0cc0d-e122-4d67-91db-84e605151982	agent.ankadikely.02	$2b$12$Xot6OhmdyJ3Bq1HBF29gV.B6Z0TwX2GWgnlpz.2QPuWJEjxHwn0Uu	bf1b7ab3-87e3-495a-bbbc-fdc70e15bdeb	62505d4e-63d7-4889-83f5-64e2e95950ff
\.


--
-- Data for Name: application_role; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.application_role (id, name, description) FROM stdin;
3a7ed2f9-98d4-4460-950b-98eca15fe7af	ADMIN	Administrateur de la plateforme
e72e2081-6296-4536-af10-8f0cd6c172b4	SUPERVISOR	Superviseur des opérations d'enrolement
bf1b7ab3-87e3-495a-bbbc-fdc70e15bdeb	AGENT	Agent chargé de l'enrolement
\.


--
-- Data for Name: centre; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.centre (id, code, name, id_fokontany, created_at) FROM stdin;
4b4704e7-11f8-4499-9d90-ca02213571e0	CTR-ILAFY	Centre Ilafy	77f0cf0d-d2c4-4dc5-b8cc-57e3d25bb561	2026-08-27 04:35:12.329178+03
62505d4e-63d7-4889-83f5-64e2e95950ff	CTR-ANKADIKELY	Centre Ankadikely	72655a56-acf5-4a3c-9491-cb3a064abb38	2026-08-27 04:35:12.329178+03
552deb5f-80cc-4b4c-af86-e733c0cf2842	CTR-IVANDRY	Centre Ivandry	55b27ee4-a901-4e71-8366-8b4f8d930771	2026-08-27 04:35:12.329178+03
\.


--
-- Data for Name: citizen; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.citizen (id, person_id, created_at, updated_at, national_unique_id) FROM stdin;
000c1869-dd9e-41e2-9f20-f557f4027220	9fe3017f-95f8-4f26-a4c8-933da500ba69	2026-09-08 10:08:12.741+03	\N	NUI-1788862092740-17235
a5392cfd-006b-40dc-a554-7126ca68173c	9bb2173d-fb11-4fee-80fd-94ad22e4d17f	2026-09-08 15:04:51.952+03	\N	NUI-1788879891950-844720
851ff7ca-f044-4eed-8f90-56cac6fe308e	944fdb6e-1783-4221-9c60-870699b1f059	2026-09-08 15:07:10.485+03	\N	NUI-1788880030484-756337
8c17575a-dc9b-42b0-8f3a-cafaa6db8b6a	12e12741-5167-4052-863c-6ee3074aa7b0	2026-09-08 15:09:17.051+03	\N	NUI-1788880157050-504078
e86b99d8-8025-4d95-8333-d64530ca2069	c7e1b089-dedd-4586-b91a-88297d4df72b	2026-09-08 18:19:13.11+03	\N	NUI-1788891553057-341694
\.


--
-- Data for Name: citizen_account; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.citizen_account (id, id_citizen, password_hash, is_empreinte_activated, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: commune; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.commune (id, district_id, name, created_at, updated_at) FROM stdin;
8ec426c9-2ff1-4e80-850d-9c76cb176dec	0459f549-25ec-405f-8097-b1d4634e50fc	Ambato	2026-08-26 20:04:05.949324+03	\N
efd44d55-42a9-48fe-b7df-4a529c6e6ff4	0459f549-25ec-405f-8097-b1d4634e50fc	Ambatolampy	2026-08-26 20:04:05.949324+03	\N
80ff7643-e4f4-4cc2-8256-7a819a0524ae	0459f549-25ec-405f-8097-b1d4634e50fc	Antehiroka	2026-08-26 20:04:05.949324+03	\N
b88675b5-4155-475e-a0c1-e2cf56ee45b3	0459f549-25ec-405f-8097-b1d4634e50fc	Ambohidratrimo	2026-08-26 20:04:05.949324+03	\N
65e120ad-578c-47e9-a2f2-2d432aa2759b	0459f549-25ec-405f-8097-b1d4634e50fc	Ambohimanjaka	2026-08-26 20:04:05.949324+03	\N
1fde422d-1ab1-46fe-9630-88d37a4c07d8	0459f549-25ec-405f-8097-b1d4634e50fc	Ambohipihaonana	2026-08-26 20:04:05.949324+03	\N
a0c1d0e1-06c8-4018-aef7-1e808e814644	0459f549-25ec-405f-8097-b1d4634e50fc	Ambohitrimanjaka	2026-08-26 20:04:05.949324+03	\N
076f5697-8aa1-4a0f-8b6f-fbf07942bcac	0459f549-25ec-405f-8097-b1d4634e50fc	Ampangabe	2026-08-26 20:04:05.949324+03	\N
3402289b-7c08-4980-92d0-f8c0d22b370e	0459f549-25ec-405f-8097-b1d4634e50fc	Ampanotokana	2026-08-26 20:04:05.949324+03	\N
033117cf-df0b-4524-bc9c-96c6d1d2ec2a	0459f549-25ec-405f-8097-b1d4634e50fc	Anjanadoria	2026-08-26 20:04:05.949324+03	\N
c1c9a28d-1966-4cf3-b6b1-411faf95a59f	0459f549-25ec-405f-8097-b1d4634e50fc	Anosiala	2026-08-26 20:04:05.949324+03	\N
2cd900b4-d256-419a-bd3b-b9e5aa976238	0459f549-25ec-405f-8097-b1d4634e50fc	Antanetibe	2026-08-26 20:04:05.949324+03	\N
ddbb1c76-21be-40a0-aaac-2c13a1d616bf	0459f549-25ec-405f-8097-b1d4634e50fc	Antsahafilo	2026-08-26 20:04:05.949324+03	\N
bdd5b2ea-10fb-4c1c-986d-5d4ac317a16c	0459f549-25ec-405f-8097-b1d4634e50fc	Avaratsena	2026-08-26 20:04:05.949324+03	\N
d4b3dde2-05f1-4477-9dad-eaff86f8b192	0459f549-25ec-405f-8097-b1d4634e50fc	Fiadanana	2026-08-26 20:04:05.949324+03	\N
4ff7be8d-ef4e-4a46-b384-f80f9837ed92	0459f549-25ec-405f-8097-b1d4634e50fc	Iarinarivo	2026-08-26 20:04:05.949324+03	\N
1fe294e1-ece2-4df4-8ce7-6cfaf025dcf6	0459f549-25ec-405f-8097-b1d4634e50fc	Ivato	2026-08-26 20:04:05.949324+03	\N
0cd12252-7714-4d2c-82ae-cab9c26c29fa	0459f549-25ec-405f-8097-b1d4634e50fc	Mahabo	2026-08-26 20:04:05.949324+03	\N
2b584cfc-34ab-4f1a-b76f-c29fcc095153	0459f549-25ec-405f-8097-b1d4634e50fc	Mahereza	2026-08-26 20:04:05.949324+03	\N
31b8e51e-5b24-4364-9ed1-ed892be88231	0459f549-25ec-405f-8097-b1d4634e50fc	Mahitsy	2026-08-26 20:04:05.949324+03	\N
f28b1070-2d9b-4f33-bc96-cfc59e20fe34	0459f549-25ec-405f-8097-b1d4634e50fc	Mananjara	2026-08-26 20:04:05.949324+03	\N
0bc03d4d-520a-4a3f-8010-046547c89156	0459f549-25ec-405f-8097-b1d4634e50fc	Manjakavaradrano	2026-08-26 20:04:05.949324+03	\N
97686902-e4c2-492f-a9f1-0d10d8bc70d7	0459f549-25ec-405f-8097-b1d4634e50fc	Merimandroso	2026-08-26 20:04:05.949324+03	\N
f9b39af5-fe45-4998-bf96-be55e6552cd6	0459f549-25ec-405f-8097-b1d4634e50fc	Talatamaty	2026-08-26 20:04:05.949324+03	\N
6265f838-e110-43e2-b225-fc3fefeb62e4	b04d939c-8953-455c-af44-a2e483c7950e	Alarobia Vatosola	2026-08-26 20:04:05.949324+03	\N
3197204f-ecef-4b7f-a4a2-c466df7404e4	b04d939c-8953-455c-af44-a2e483c7950e	Alatsinainy Bakaro	2026-08-26 20:04:05.949324+03	\N
95fcbc78-6923-492e-88b3-952252069804	b04d939c-8953-455c-af44-a2e483c7950e	Ambohimiadana	2026-08-26 20:04:05.949324+03	\N
cd082b60-1484-47a3-9b86-45550b3a5d8d	b04d939c-8953-455c-af44-a2e483c7950e	Andohariana	2026-08-26 20:04:05.949324+03	\N
62b2fcee-2998-4b75-82e2-7cdec203b379	b04d939c-8953-455c-af44-a2e483c7950e	Andramasina	2026-08-26 20:04:05.949324+03	\N
4a996e53-375d-4687-bca8-7a31f603912e	b04d939c-8953-455c-af44-a2e483c7950e	Anjoma Faliarivo	2026-08-26 20:04:05.949324+03	\N
9035c9c7-31ec-4cae-986c-5f259009f47a	b04d939c-8953-455c-af44-a2e483c7950e	Anosibe Trimoloharano	2026-08-26 20:04:05.949324+03	\N
da1c22d4-7c5b-448c-8aa8-87ed4de85734	b04d939c-8953-455c-af44-a2e483c7950e	Antotohazo	2026-08-26 20:04:05.949324+03	\N
395f92fb-7f4e-4061-b119-588eb6675e49	b04d939c-8953-455c-af44-a2e483c7950e	Fitsinjovana Bakaro	2026-08-26 20:04:05.949324+03	\N
b8426c8d-7a3d-4cdd-96c2-d40087ef063a	b04d939c-8953-455c-af44-a2e483c7950e	Mandrosoa	2026-08-26 20:04:05.949324+03	\N
b29f17c2-c3d2-4fc6-bebc-f8ebd6aa65be	b04d939c-8953-455c-af44-a2e483c7950e	Morarano Soa Firaisana	2026-08-26 20:04:05.949324+03	\N
f5d54140-0fb1-447b-bd24-bc7bd57f209b	b04d939c-8953-455c-af44-a2e483c7950e	Sabotsy Ambohitromby	2026-08-26 20:04:05.949324+03	\N
e663b4de-f421-4d41-8312-cd58cf1f542b	b04d939c-8953-455c-af44-a2e483c7950e	Sabotsy Manjakavahoaka	2026-08-26 20:04:05.949324+03	\N
611f89ae-1270-410e-af01-deffb6667592	b04d939c-8953-455c-af44-a2e483c7950e	Tankafatra	2026-08-26 20:04:05.949324+03	\N
1e17b461-7e93-4e82-90c8-088409870e7e	2e3d8852-88ab-4f51-aa03-71f16565d583	Alakamisy	2026-08-26 20:04:05.949324+03	\N
f58eb45d-64d5-4fdd-9d19-494c8427f78b	2e3d8852-88ab-4f51-aa03-71f16565d583	Ambatomanoina	2026-08-26 20:04:05.949324+03	\N
9fbc0f3b-f631-4a2c-b05d-4ec493e59104	2e3d8852-88ab-4f51-aa03-71f16565d583	Amboasary Nord	2026-08-26 20:04:05.949324+03	\N
e1b56bc2-90bb-4d04-b8c2-6b23d792e2b4	2e3d8852-88ab-4f51-aa03-71f16565d583	Ambohibary Vohilena	2026-08-26 20:04:05.949324+03	\N
23ac8614-87ac-4405-bc1a-b7d3e7aea581	2e3d8852-88ab-4f51-aa03-71f16565d583	Ambohimarina Marovazaha	2026-08-26 20:04:05.949324+03	\N
5fda2af3-6e38-4a91-8eab-306f0c197685	2e3d8852-88ab-4f51-aa03-71f16565d583	Ambohimirary	2026-08-26 20:04:05.949324+03	\N
fba8db4a-4f53-4b5d-81ef-06f815a94e3a	2e3d8852-88ab-4f51-aa03-71f16565d583	Ambongamarina	2026-08-26 20:04:05.949324+03	\N
f20245e4-495f-4f5a-ab90-c8e785062a9c	2e3d8852-88ab-4f51-aa03-71f16565d583	Amparatanjona	2026-08-26 20:04:05.949324+03	\N
b4f5a928-1a25-4834-83da-a36feae4478c	2e3d8852-88ab-4f51-aa03-71f16565d583	Analaroa	2026-08-26 20:04:05.949324+03	\N
31967c0b-6fed-4e1e-af15-64d620f639a4	2e3d8852-88ab-4f51-aa03-71f16565d583	Andranomisa	2026-08-26 20:04:05.949324+03	\N
4c29adba-8512-443e-b752-e9072c58ad35	2e3d8852-88ab-4f51-aa03-71f16565d583	Androvakely	2026-08-26 20:04:05.949324+03	\N
b3a2b377-04e5-43fa-abc7-bd6d8eaee39c	2e3d8852-88ab-4f51-aa03-71f16565d583	Anjozorobe	2026-08-26 20:04:05.949324+03	\N
206b228c-7dbe-4771-8a44-530badd1d1e7	2e3d8852-88ab-4f51-aa03-71f16565d583	Antanetibe	2026-08-26 20:04:05.949324+03	\N
950cbd0a-3eae-48cc-b1e9-0ee1aa9f936b	2e3d8852-88ab-4f51-aa03-71f16565d583	Belanitra	2026-08-26 20:04:05.949324+03	\N
c584e6a7-71de-4d75-8d05-e0e033bcc2be	2e3d8852-88ab-4f51-aa03-71f16565d583	Beronono	2026-08-26 20:04:05.949324+03	\N
3db69d75-46ba-431d-b97a-94b8204bee7b	2e3d8852-88ab-4f51-aa03-71f16565d583	Betatao	2026-08-26 20:04:05.949324+03	\N
60328eb0-b580-4e2b-bc51-5573cbff9340	2e3d8852-88ab-4f51-aa03-71f16565d583	Mangamila	2026-08-26 20:04:05.949324+03	\N
b7352fa9-d44e-4e4c-8b4b-0b35cf88d8d8	2e3d8852-88ab-4f51-aa03-71f16565d583	Marotsipoy	2026-08-26 20:04:05.949324+03	\N
fec23ddf-604e-4afe-9135-08c6f96c3fe6	2e3d8852-88ab-4f51-aa03-71f16565d583	Tsarasaotra Andona	2026-08-26 20:04:05.949324+03	\N
e2c3d7b1-24ac-4422-96e0-5c9547d1c2d5	2b8f5243-740b-4ace-92ce-739140990752	Ambohitromby	2026-08-26 20:04:05.949324+03	\N
e7091066-3145-448c-88f2-ae7cae6a7548	2b8f5243-740b-4ace-92ce-739140990752	Ambolotarakely	2026-08-26 20:04:05.949324+03	\N
c2d01062-d986-465d-a7af-8199e0c34725	2b8f5243-740b-4ace-92ce-739140990752	Andranomiely	2026-08-26 20:04:05.949324+03	\N
66061650-c60f-4890-a51c-c18a1f4a5f36	2b8f5243-740b-4ace-92ce-739140990752	Ankazobe	2026-08-26 20:04:05.949324+03	\N
77e57df9-6688-461f-b080-ebe43f0eaafe	2b8f5243-740b-4ace-92ce-739140990752	Antakavana	2026-08-26 20:04:05.949324+03	\N
c5f95142-6a04-4cfa-91d6-8f775a8d4dd0	2b8f5243-740b-4ace-92ce-739140990752	Antotohazo	2026-08-26 20:04:05.949324+03	\N
40214332-3495-4d99-96de-f82a83a3e398	2b8f5243-740b-4ace-92ce-739140990752	Fiadanana	2026-08-26 20:04:05.949324+03	\N
d0ab4fd0-e3f0-4152-bc5d-f1621dfb37f3	2b8f5243-740b-4ace-92ce-739140990752	Fihaonana	2026-08-26 20:04:05.949324+03	\N
b6d2ac70-8a24-42e2-bfdf-21fd476ba4e8	2b8f5243-740b-4ace-92ce-739140990752	Kiangara	2026-08-26 20:04:05.949324+03	\N
234bb62d-52b2-4721-ba2a-ba140a9c1ca2	2b8f5243-740b-4ace-92ce-739140990752	Mahavelona	2026-08-26 20:04:05.949324+03	\N
731a2cdf-790f-4690-9a17-2caf6f4d9cb3	2b8f5243-740b-4ace-92ce-739140990752	Mangasoavina	2026-08-26 20:04:05.949324+03	\N
96f5f361-fd73-42d6-adc4-1e767f17c598	2b8f5243-740b-4ace-92ce-739140990752	Marondry	2026-08-26 20:04:05.949324+03	\N
e9c7ad4f-3625-4add-a710-35f92ec70f91	2b8f5243-740b-4ace-92ce-739140990752	Miantso	2026-08-26 20:04:05.949324+03	\N
f2418b48-8f77-4199-8763-a121ca8092d0	2b8f5243-740b-4ace-92ce-739140990752	Talata-Angavo	2026-08-26 20:04:05.949324+03	\N
7e613a99-8f09-45fb-9721-5a1d7032f8af	2b8f5243-740b-4ace-92ce-739140990752	Tsaramasoandro	2026-08-26 20:04:05.949324+03	\N
8f4e5fc4-cb9e-45e3-9520-c2a8a6875c27	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Alakamisy Fenoarivo	2026-08-26 20:04:05.949324+03	\N
046d1061-b91d-4393-ab24-c7adf3dcc6ed	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Alatsinainy Ambazaha	2026-08-26 20:04:05.949324+03	\N
54dc4c6c-42e5-49a0-9665-59e0675e9207	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ambalavao	2026-08-26 20:04:05.949324+03	\N
46a8ed84-2a80-4eed-b95d-cdc8ec93f9c4	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ambatofahavalo	2026-08-26 20:04:05.949324+03	\N
a9bc1c49-a195-47ee-a957-5ec96613648d	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ambavahaditokana	2026-08-26 20:04:05.949324+03	\N
d262c1d9-bf76-42bd-a24a-693e0b1df982	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ambohidrapeto	2026-08-26 20:04:05.949324+03	\N
c3528b28-52dd-4685-9280-86b6256f1c80	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ambohijanaka	2026-08-26 20:04:05.949324+03	\N
6ae8a69f-236f-4c81-925f-4ca11b79f979	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ampahitrosy	2026-08-26 20:04:05.949324+03	\N
a3c1c072-18b4-472c-b58c-c9124a02d4fa	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ampanefy	2026-08-26 20:04:05.949324+03	\N
5b359835-6786-48a3-ba0e-d9d30d5e310d	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ampitatafika	2026-08-26 20:04:05.949324+03	\N
c2fd2bc2-9049-44f1-bb2c-590677383540	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Andoharanofotsy	2026-08-26 20:04:05.949324+03	\N
26324437-5e81-4984-b7e0-d4c60edb17b3	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Andranonahoatra	2026-08-26 20:04:05.949324+03	\N
80efaff5-4bd3-4ba0-bdd5-89a0eca2e4c4	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Androhibe	2026-08-26 20:04:05.949324+03	\N
27c6a330-1670-4a21-a7dc-7721317d4ec3	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ankadimanga	2026-08-26 20:04:05.949324+03	\N
ca25900e-5978-4695-8d9d-34d68fb0c5d2	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Ankaraobato	2026-08-26 20:04:05.949324+03	\N
7c8d80d8-30a8-4f1a-8618-774ba07f3159	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Anosizato Andrefana	2026-08-26 20:04:05.949324+03	\N
a71d1b6a-2b95-4e34-a1cc-541f34d4bdce	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Antanetikely	2026-08-26 20:04:05.949324+03	\N
ebc94bc0-2c52-43c2-aa75-6ba386676062	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Bemasoandro	2026-08-26 20:04:05.949324+03	\N
1f1d807b-5fa9-4bf3-8951-2c8e95b5868b	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Bongatsara	2026-08-26 20:04:05.949324+03	\N
92c76a92-a090-4fd0-a685-245474f7862d	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Fenoarivo	2026-08-26 20:04:05.949324+03	\N
1df37f7a-34e9-40de-a41d-fb071e74ab86	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Fiombonana	2026-08-26 20:04:05.949324+03	\N
5ff7e10b-1b92-47ca-8f7b-e5c8214a3b84	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Itaosy	2026-08-26 20:04:05.949324+03	\N
78807b35-5344-47aa-b2f5-802ac6138957	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Soalandy	2026-08-26 20:04:05.949324+03	\N
4cc9e1ee-47bd-40ad-968f-ddeed287dc67	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Soavina	2026-08-26 20:04:05.949324+03	\N
d99d1571-c998-42d7-b8b2-1527e8b2407a	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Tanjombato	2026-08-26 20:04:05.949324+03	\N
37833d1a-fb61-47c9-bf07-93a4c1083e44	af85fdca-9a2f-440d-8a95-7b47e2510b4f	Tsiafahy	2026-08-26 20:04:05.949324+03	\N
0cbb6240-77bc-4591-89b2-81b50c5150b8	4ff37ada-b76f-42ae-ac25-fcc50541832c	Alasora	2026-08-26 20:04:05.949324+03	\N
8027c448-726b-47e2-b6ab-cbcba9aaff4e	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ambohimalaza Miray	2026-08-26 20:04:05.949324+03	\N
9384fcf1-d9f1-4b06-8ea6-be41d7568dcd	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ambohimanambola	2026-08-26 20:04:05.949324+03	\N
b7dec64b-a079-4181-933b-54f1e1d482ca	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ambohimanga Rova	2026-08-26 20:04:05.949324+03	\N
44bb94ac-7335-43af-b5ef-59beb3097454	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ambohimangakely	2026-08-26 20:04:05.949324+03	\N
075920dc-25e2-45ba-b9c2-ebc8e55ccfa2	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ambohidrabiby	2026-08-26 20:04:05.949324+03	\N
1e516b89-80cd-4291-90f1-7be91c38775d	4ff37ada-b76f-42ae-ac25-fcc50541832c	Anjeva Gara	2026-08-26 20:04:05.949324+03	\N
00015f0f-ecb2-499c-afe4-3caf7ebb8639	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ankadikely Ilafy	2026-08-26 20:04:05.949324+03	\N
b371ad53-51bf-41e4-909d-04a055361e60	4ff37ada-b76f-42ae-ac25-fcc50541832c	Ankadinandriana	2026-08-26 20:04:05.949324+03	\N
a7419533-3952-4953-9288-3e67f89fd5a1	4ff37ada-b76f-42ae-ac25-fcc50541832c	Anosy Avaratra	2026-08-26 20:04:05.949324+03	\N
acdcfb3f-6d7c-4ef1-806d-f8d7e1ad6eb0	4ff37ada-b76f-42ae-ac25-fcc50541832c	Fieferana	2026-08-26 20:04:05.949324+03	\N
9922e7bc-5ae8-425c-8039-5347e6caae81	4ff37ada-b76f-42ae-ac25-fcc50541832c	Manandriana	2026-08-26 20:04:05.949324+03	\N
c0ef58a4-d5b2-4a73-85e4-19f3180ce8d4	4ff37ada-b76f-42ae-ac25-fcc50541832c	Masindray	2026-08-26 20:04:05.949324+03	\N
18a78967-bdfe-4e7b-a32c-2ae7c428e902	4ff37ada-b76f-42ae-ac25-fcc50541832c	Sabotsy Namehana	2026-08-26 20:04:05.949324+03	\N
cb7916bd-0dc0-4b44-a82e-6a4c71a5e464	4ff37ada-b76f-42ae-ac25-fcc50541832c	Talata Volonondry	2026-08-26 20:04:05.949324+03	\N
63d39015-e1c4-4c0e-b8f3-b13fb418cd42	4ff37ada-b76f-42ae-ac25-fcc50541832c	Vilihazo	2026-08-26 20:04:05.949324+03	\N
414fdd7d-f545-4ab0-810f-037c476731ca	05ca0b68-99ac-42de-a3c9-e523dc5cf1d6	Antananarivo	2026-08-26 20:04:05.949324+03	\N
2204094c-80e4-4a50-ad53-e5d0104e23f6	502119d5-b7be-4ab4-8363-e2c3df4778e8	Alarobia	2026-08-26 20:04:05.949324+03	\N
40c7c06d-d585-4534-a870-17bd879b1dc9	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambanitsena	2026-08-26 20:04:05.949324+03	\N
37b2c1bc-06b8-41cc-bbcd-aeedad3d30b1	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambatolaona	2026-08-26 20:04:05.949324+03	\N
2f865b3f-205f-4ea9-b7c1-677b1a4c4c43	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambatomanga	2026-08-26 20:04:05.949324+03	\N
40142a1c-da86-449c-80cf-6ac200fb8baa	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambatomena	2026-08-26 20:04:05.949324+03	\N
98f2d13c-9f78-4f5a-87dd-907f57736b00	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohibao Sud	2026-08-26 20:04:05.949324+03	\N
9ca2f77e-af04-4477-a4ff-8c583d5bb09d	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohibary	2026-08-26 20:04:05.949324+03	\N
25366b8c-dbb9-40b1-a8a1-460c359b6a11	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohitrandriamanitra	2026-08-26 20:04:05.949324+03	\N
e9f91906-fa80-4a70-afe5-a0859b7dc419	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohitrolomahitsy	2026-08-26 20:04:05.949324+03	\N
ccf25592-fed7-4737-8b31-752d2d525f63	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohitrony	2026-08-26 20:04:05.949324+03	\N
0f6f9722-922d-4a36-9794-a9539089c235	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ambohitseheno	2026-08-26 20:04:05.949324+03	\N
87c3087a-5dda-4fd6-a68b-758c56fcdadd	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ampaneva	2026-08-26 20:04:05.949324+03	\N
0f83080d-d73b-4063-8079-cb712ffa2fe4	502119d5-b7be-4ab4-8363-e2c3df4778e8	Anjepy	2026-08-26 20:04:05.949324+03	\N
faaed112-e388-4604-9727-3525e85a308f	502119d5-b7be-4ab4-8363-e2c3df4778e8	Anjoma Betoho	2026-08-26 20:04:05.949324+03	\N
437e08a8-6c95-40a0-a434-f7e940b3b269	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ankazodandy	2026-08-26 20:04:05.949324+03	\N
e7bc931f-da29-4a18-8fba-5160040a8d4b	502119d5-b7be-4ab4-8363-e2c3df4778e8	Antsahalalina	2026-08-26 20:04:05.949324+03	\N
eb041046-3ea4-4c57-b640-3fae715250b5	502119d5-b7be-4ab4-8363-e2c3df4778e8	Manjakandriana	2026-08-26 20:04:05.949324+03	\N
50d663a9-c87b-48f2-96b1-6fe52d23db09	502119d5-b7be-4ab4-8363-e2c3df4778e8	Mantasoa	2026-08-26 20:04:05.949324+03	\N
b2e9b8dd-9391-4c88-8909-f88fa8fb70b3	502119d5-b7be-4ab4-8363-e2c3df4778e8	Merikanjaka	2026-08-26 20:04:05.949324+03	\N
1f5fa06f-8c8c-4be8-adab-5d5986e05cc5	502119d5-b7be-4ab4-8363-e2c3df4778e8	Miadanandriana	2026-08-26 20:04:05.949324+03	\N
dde90636-8143-4e82-ba2a-58188ca14c09	502119d5-b7be-4ab4-8363-e2c3df4778e8	Nandihizana Carion	2026-08-26 20:04:05.949324+03	\N
6bf02064-209b-4ef5-8498-0383d6b6dae9	502119d5-b7be-4ab4-8363-e2c3df4778e8	Ranovao	2026-08-26 20:04:05.949324+03	\N
47c2a440-6981-4ed0-b5a4-6fde4068551f	502119d5-b7be-4ab4-8363-e2c3df4778e8	Sadabe	2026-08-26 20:04:05.949324+03	\N
ba9c93ac-d9f6-4561-a4ec-ecf022f39a9b	502119d5-b7be-4ab4-8363-e2c3df4778e8	Sambaina	2026-08-26 20:04:05.949324+03	\N
d781e966-78b6-4eef-9be2-805c1fae282a	502119d5-b7be-4ab4-8363-e2c3df4778e8	Soavinandriana (Ambohidratrimoanala)	2026-08-26 20:04:05.949324+03	\N
46f786e5-284d-43cc-8995-59980b7120e2	e1ab3513-b01d-4366-85e0-7cbba179b020	Ambatamainty Sud	2026-08-26 20:04:05.949324+03	\N
b137b3e9-3f1f-4c25-8996-760254e0463a	e1ab3513-b01d-4366-85e0-7cbba179b020	Ambohitromby	2026-08-26 20:04:05.949324+03	\N
0e5d5c42-68a0-4a4d-8724-22bea9a609eb	e1ab3513-b01d-4366-85e0-7cbba179b020	Fenoarivobe	2026-08-26 20:04:05.949324+03	\N
de4e6b1b-9064-4613-b6b4-ff6563c9228c	e1ab3513-b01d-4366-85e0-7cbba179b020	Firavahana	2026-08-26 20:04:05.949324+03	\N
23956328-ae11-4016-9613-badb5380d568	e1ab3513-b01d-4366-85e0-7cbba179b020	Kiranomena	2026-08-26 20:04:05.949324+03	\N
2ae10a69-733d-4c69-9aeb-24ac1ed1f69b	e1ab3513-b01d-4366-85e0-7cbba179b020	Mahajeby	2026-08-26 20:04:05.949324+03	\N
472d68c8-5d88-4649-a217-a52a63f09d7c	e1ab3513-b01d-4366-85e0-7cbba179b020	Morarano Maritampóna	2026-08-26 20:04:05.949324+03	\N
41a4aa2d-8817-4002-9aba-807c8e679ede	e1ab3513-b01d-4366-85e0-7cbba179b020	Tsinjoarivo 22	2026-08-26 20:04:05.949324+03	\N
19d82d91-face-4d7f-b1d2-c0254ee26fb3	e1ab3513-b01d-4366-85e0-7cbba179b020	Mangatany	2026-08-26 20:04:05.949324+03	\N
1415c43e-d242-4846-8be6-c54a31dbb51d	e1ab3513-b01d-4366-85e0-7cbba179b020	Andriampotsy	2026-08-26 20:04:05.949324+03	\N
988568d1-82e3-4866-8030-ecb9bccc0eb0	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Ambalanirana	2026-08-26 20:04:05.949324+03	\N
09e48a27-2130-4c41-979f-b572cadfec63	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Ambararatabe	2026-08-26 20:04:05.949324+03	\N
dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Ambatolampy	2026-08-26 20:04:05.949324+03	\N
7a2b658b-cdee-403b-a2b4-3eab0cf9b60c	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Ankadinondry Sakay	2026-08-26 20:04:05.949324+03	\N
42c75ad5-6d22-4581-bb51-a2810d9de887	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Ankerana Nord	2026-08-26 20:04:05.949324+03	\N
54cdf0a6-38c9-44e0-9242-e5a104686572	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Anosy	2026-08-26 20:04:05.949324+03	\N
e4e30966-0637-4028-be65-a78a0e185656	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Belobaka	2026-08-26 20:04:05.949324+03	\N
a2d5c7c4-b4e9-4631-a0f7-074a1f2205ba	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Bemahatazana	2026-08-26 20:04:05.949324+03	\N
72474b77-b63c-400a-abe4-301ec07adb73	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Bevato	2026-08-26 20:04:05.949324+03	\N
30a9bd68-a661-40e2-a3fa-a1fbb1fe9e77	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Fierenana	2026-08-26 20:04:05.949324+03	\N
d143499f-3180-4581-879a-5fea416bef67	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Mahasolo	2026-08-26 20:04:05.949324+03	\N
71f4be4f-913f-4a91-ac49-1218d44402c5	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Maroharona	2026-08-26 20:04:05.949324+03	\N
9bc6933b-6e77-4baf-8797-0f8addd91f2e	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Maritampóna	2026-08-26 20:04:05.949324+03	\N
0c57ea9d-c89b-4cca-bdb6-1d7647b504cf	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Miandrarivo	2026-08-26 20:04:05.949324+03	\N
a66c10ca-3f90-4730-9a68-fc27274334e3	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Soanierana	2026-08-26 20:04:05.949324+03	\N
33c344a5-bf52-4532-8cc4-9d9a1d556447	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Tsinjoarivo-Imanga	2026-08-26 20:04:05.949324+03	\N
2f36c96b-c002-40b7-84cf-2d2a65980bc0	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Tsiroanomandidy Fihaonana	2026-08-26 20:04:05.949324+03	\N
3514cedb-e4a6-4d5c-ad83-cf7cfc7e5cbd	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Tsiroanomandidy Ville	2026-08-26 20:04:05.949324+03	\N
20dd1d77-e052-4b37-81fd-f229bf4c848a	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Antsahalava	2026-08-26 20:04:05.949324+03	\N
1c27cfe3-1ae3-4087-9c7d-43344d2ca9ca	5dc1b9f5-f537-4383-8ece-d64ddd6147f0	Fiadanantsoa	2026-08-26 20:04:05.949324+03	\N
79da72ea-ff9a-47cd-a6a9-02431435adf0	caaa2d03-43fa-43fb-a01d-223c05025fff	Alakamisikely	2026-08-26 20:04:05.949324+03	\N
3dcd2d88-8aec-4b24-a001-b85ade2368c1	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambatomanga	2026-08-26 20:04:05.949324+03	\N
27221cee-c283-45e2-acbe-cddee2071640	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambatomirahavavy	2026-08-26 20:04:05.949324+03	\N
eccff8ae-d3e9-42ae-9f1d-ad608947379b	caaa2d03-43fa-43fb-a01d-223c05025fff	Amboanana	2026-08-26 20:04:05.949324+03	\N
3f72615e-abc7-467c-8b2c-46f72489efe5	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambohimandry	2026-08-26 20:04:05.949324+03	\N
7d4fef16-154e-40f5-a241-9fa9b16dc902	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambohimasina	2026-08-26 20:04:05.949324+03	\N
9cc99659-7534-429c-8e1c-dc6577209144	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambohipandrano	2026-08-26 20:04:05.949324+03	\N
f3139b04-c4ed-4eac-802d-d5bcfd9127b1	caaa2d03-43fa-43fb-a01d-223c05025fff	Ambohitrambo	2026-08-26 20:04:05.949324+03	\N
6115b29a-b8a9-46da-aaf2-205e2e14c59a	caaa2d03-43fa-43fb-a01d-223c05025fff	Ampahimanga	2026-08-26 20:04:05.949324+03	\N
73235deb-6241-4353-b2d7-f1912ddba086	caaa2d03-43fa-43fb-a01d-223c05025fff	Andranomiely	2026-08-26 20:04:05.949324+03	\N
5ce39597-4f01-4ea0-9dbc-136b72dc6ab8	caaa2d03-43fa-43fb-a01d-223c05025fff	Antambolo	2026-08-26 20:04:05.949324+03	\N
5e7faa98-15c2-4b18-aa65-8bab23270859	caaa2d03-43fa-43fb-a01d-223c05025fff	Antenimbe	2026-08-26 20:04:05.949324+03	\N
5941074a-f149-43ad-88ad-84e065a28f25	caaa2d03-43fa-43fb-a01d-223c05025fff	Arivonimamo	2026-08-26 20:04:05.949324+03	\N
1bc0e954-925b-4b75-97bf-3d169bb0c0d5	caaa2d03-43fa-43fb-a01d-223c05025fff	Arivonimamo II	2026-08-26 20:04:05.949324+03	\N
413835cd-01f7-409f-a1c8-e91b57a84a57	caaa2d03-43fa-43fb-a01d-223c05025fff	Imerintsiatosika	2026-08-26 20:04:05.949324+03	\N
1fbe7b5d-3f58-417c-b11b-5e6a479a34f4	caaa2d03-43fa-43fb-a01d-223c05025fff	Mahatsinjo Est	2026-08-26 20:04:05.949324+03	\N
fbbaefde-6e79-454e-9a12-cbfea66decfe	caaa2d03-43fa-43fb-a01d-223c05025fff	Manalalondo	2026-08-26 20:04:05.949324+03	\N
5d3df8ff-546e-4101-8db2-94cc1fec4e65	caaa2d03-43fa-43fb-a01d-223c05025fff	Marofangady	2026-08-26 20:04:05.949324+03	\N
bf57bac2-70cf-4371-9f07-b30d821528f5	caaa2d03-43fa-43fb-a01d-223c05025fff	Miandrandra	2026-08-26 20:04:05.949324+03	\N
9b298b59-8319-4ef2-86e7-8f80219bc3a9	caaa2d03-43fa-43fb-a01d-223c05025fff	Miantsoarivo	2026-08-26 20:04:05.949324+03	\N
db1d6421-5fc0-4ee4-a97f-4c1b1aee2403	caaa2d03-43fa-43fb-a01d-223c05025fff	Morafeno	2026-08-26 20:04:05.949324+03	\N
e2c76d3d-a5e6-4010-b32b-709d2eef682b	caaa2d03-43fa-43fb-a01d-223c05025fff	Morarano	2026-08-26 20:04:05.949324+03	\N
6f88bc50-0e75-4983-a4fa-401a06b9875f	caaa2d03-43fa-43fb-a01d-223c05025fff	Talata Tsimadilo	2026-08-26 20:04:05.949324+03	\N
95543c6d-f8ec-4105-827d-1d470988003d	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Alatsinainikely	2026-08-26 20:04:05.949324+03	\N
cd0221ad-9964-41e7-8235-c877ae449167	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Ambatomanjaka	2026-08-26 20:04:05.949324+03	\N
8b04d13d-56e2-4d37-8358-46ed1d817a23	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Analavory	2026-08-26 20:04:05.949324+03	\N
84788724-12ab-42c4-9de9-cfd744599167	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Andolofotsy	2026-08-26 20:04:05.949324+03	\N
56300db0-a4cc-4f61-8a90-0674c8813b8c	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Anosibe-Ifanja	2026-08-26 20:04:05.949324+03	\N
c5c88d73-6caa-4261-b20d-9f42cf69737d	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Antoby Est	2026-08-26 20:04:05.949324+03	\N
927e8b78-277a-4b17-b178-fa4903877543	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Manazary	2026-08-26 20:04:05.949324+03	\N
fe5870e5-5b7c-41b4-b8a6-19c82dea6622	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Mandiavato	2026-08-26 20:04:05.949324+03	\N
da452fe9-2cc3-4fe1-83b4-560602457f9b	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Miarinarivo	2026-08-26 20:04:05.949324+03	\N
d77cf3d9-8459-43f0-b9c3-b81dcc3e6887	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Miarinarivo II	2026-08-26 20:04:05.949324+03	\N
f7bcb187-819a-4f05-9217-3817b6a36c64	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Sarobaratra	2026-08-26 20:04:05.949324+03	\N
26656fdd-d75c-447f-b09f-d044dbf307df	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Soamahamanina	2026-08-26 20:04:05.949324+03	\N
46139ec3-abb6-4060-a454-ba1f562e18d5	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Soavimbazaha	2026-08-26 20:04:05.949324+03	\N
f770dfe8-31b6-46c8-ab4f-3c4d5a6fa484	022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	Zoma Bealoka	2026-08-26 20:04:05.949324+03	\N
d471211f-ff9c-43e5-8578-904fdd86461c	e52117d6-222f-4669-bff8-4d16edaea3e7	Ambatoasana Centre	2026-08-26 20:04:05.949324+03	\N
665c4c2e-64e2-4787-aab9-6e938e7bf5b6	e52117d6-222f-4669-bff8-4d16edaea3e7	Amberomanga	2026-08-26 20:04:05.949324+03	\N
bdd1e36c-6a3d-4eca-a86c-4bb9b47e2d7b	e52117d6-222f-4669-bff8-4d16edaea3e7	Amparaky	2026-08-26 20:04:05.949324+03	\N
7003f490-7d6e-4834-97dd-63d9248fabeb	e52117d6-222f-4669-bff8-4d16edaea3e7	Amparibohitra	2026-08-26 20:04:05.949324+03	\N
82167650-b4eb-4eca-b54e-326f49b0340d	e52117d6-222f-4669-bff8-4d16edaea3e7	Ampary	2026-08-26 20:04:05.949324+03	\N
68a74b32-e7c4-4769-87c7-abc1ffcb5836	e52117d6-222f-4669-bff8-4d16edaea3e7	Ampefy	2026-08-26 20:04:05.949324+03	\N
ea7f5b04-f15a-4dcc-a144-f4f9d03639c7	e52117d6-222f-4669-bff8-4d16edaea3e7	Ankaranana	2026-08-26 20:04:05.949324+03	\N
7b9797b5-d5f0-4854-93c3-e429c2cfe940	e52117d6-222f-4669-bff8-4d16edaea3e7	Ankisabe	2026-08-26 20:04:05.949324+03	\N
93cd249a-8070-454e-b3d5-d585df3921d1	e52117d6-222f-4669-bff8-4d16edaea3e7	Antanetibe	2026-08-26 20:04:05.949324+03	\N
ca6d64c5-b65d-4096-9fbc-29cbf1eede20	e52117d6-222f-4669-bff8-4d16edaea3e7	Dondona	2026-08-26 20:04:05.949324+03	\N
0466f326-4af9-4926-ab81-7c07f7be87d7	e52117d6-222f-4669-bff8-4d16edaea3e7	Mahavelona	2026-08-26 20:04:05.949324+03	\N
41344976-ad55-49ad-a2c4-e8691c612b6a	e52117d6-222f-4669-bff8-4d16edaea3e7	Mananasy	2026-08-26 20:04:05.949324+03	\N
959e41c8-eac3-4d53-a172-86508499d75c	e52117d6-222f-4669-bff8-4d16edaea3e7	Masindray	2026-08-26 20:04:05.949324+03	\N
862d953b-0d31-44d8-b8d6-c43e9c0b9e4c	e52117d6-222f-4669-bff8-4d16edaea3e7	Soavinandriana	2026-08-26 20:04:05.949324+03	\N
2db85e3b-ebf0-4d4f-9c6e-0a1ecf114901	e52117d6-222f-4669-bff8-4d16edaea3e7	Tamponala	2026-08-26 20:04:05.949324+03	\N
1929cad0-da29-4750-9595-cf2f57d4440b	e52117d6-222f-4669-bff8-4d16edaea3e7	Ambohidanerana	2026-08-26 20:04:05.949324+03	\N
6528bc3d-3e2b-43ec-b36b-7d52e938d63b	06597f99-5051-4398-99f6-3d186273f00f	Ambatolampy	2026-08-26 20:04:05.949324+03	\N
4b02ebc1-d81a-47de-8243-0d8d63f32315	06597f99-5051-4398-99f6-3d186273f00f	Ambatondrakalavao	2026-08-26 20:04:05.949324+03	\N
532ce074-7225-4055-93f9-8a13ac22b4de	06597f99-5051-4398-99f6-3d186273f00f	Ambodifarihy	2026-08-26 20:04:05.949324+03	\N
ec1c0a64-424e-483d-98fa-300da5699cf6	06597f99-5051-4398-99f6-3d186273f00f	Ambohimpiahanana	2026-08-26 20:04:05.949324+03	\N
9255af89-a57d-495c-8d46-285b566ed239	06597f99-5051-4398-99f6-3d186273f00f	Andranovelona	2026-08-26 20:04:05.949324+03	\N
197e2185-36e7-43d5-a6e9-1021651f4480	06597f99-5051-4398-99f6-3d186273f00f	Andravola Vohipeno	2026-08-26 20:04:05.949324+03	\N
24c2edb7-75df-41a7-bd66-6da8dc986592	06597f99-5051-4398-99f6-3d186273f00f	Andriambilany	2026-08-26 20:04:05.949324+03	\N
4f80c2fe-a51d-4a05-bb9e-a9bcf1bf6476	06597f99-5051-4398-99f6-3d186273f00f	Antakasina	2026-08-26 20:04:05.949324+03	\N
cc7eaf76-1053-45fd-8142-50680e9fca05	06597f99-5051-4398-99f6-3d186273f00f	Antanamalaza	2026-08-26 20:04:05.949324+03	\N
8df8e33f-b342-4346-8f23-bc8033815427	06597f99-5051-4398-99f6-3d186273f00f	Antanimasaka	2026-08-26 20:04:05.949324+03	\N
04fac0e3-c662-4820-af47-cd91154460ba	06597f99-5051-4398-99f6-3d186273f00f	Antsampandrano	2026-08-26 20:04:05.949324+03	\N
3f2deb40-5140-4d40-9fe7-4527084e0383	06597f99-5051-4398-99f6-3d186273f00f	Behenjy	2026-08-26 20:04:05.949324+03	\N
d49ad21c-f969-4ec5-80f6-38cf7135228e	06597f99-5051-4398-99f6-3d186273f00f	Belambo Firaisana	2026-08-26 20:04:05.949324+03	\N
bdcd4c57-9d0a-4c4c-8778-bb8cb3e59b9d	06597f99-5051-4398-99f6-3d186273f00f	Manjakatompo	2026-08-26 20:04:05.949324+03	\N
7db562ad-6c20-42e0-a538-3796af80a289	06597f99-5051-4398-99f6-3d186273f00f	Morarano	2026-08-26 20:04:05.949324+03	\N
fd127b2f-1427-4ffc-846f-b919a3bf281f	06597f99-5051-4398-99f6-3d186273f00f	Sabotsy Namatoana	2026-08-26 20:04:05.949324+03	\N
b836ee40-4992-4c70-bbd5-24ffd392ee36	06597f99-5051-4398-99f6-3d186273f00f	Tsiafajavona Ankaratra	2026-08-26 20:04:05.949324+03	\N
f11ac0c2-70bc-439f-a29d-dbeaef6030ff	06597f99-5051-4398-99f6-3d186273f00f	Tsinjoarivo	2026-08-26 20:04:05.949324+03	\N
cffa80bd-d8ed-421e-b954-cd925a6b0bef	06597f99-5051-4398-99f6-3d186273f00f	Andriantsivalana	2026-08-26 20:04:05.949324+03	\N
49c4705f-bce9-470f-9c56-a1dba53d4487	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambatolahy	2026-08-26 20:04:05.949324+03	\N
0fc88542-927d-46ec-a8ad-7da6358eee42	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambatomiady	2026-08-26 20:04:05.949324+03	\N
89566c62-657d-470a-9dc1-45adc74166a3	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambatotsipihana	2026-08-26 20:04:05.949324+03	\N
4db5b4fa-58fb-4e08-ab87-f63b944bbaaa	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambodiriana	2026-08-26 20:04:05.949324+03	\N
d94fa135-3b30-417c-8ea8-ccd0ddcbbd61	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambohimandroso	2026-08-26 20:04:05.949324+03	\N
a155e0f6-108c-4985-8efc-8d6fbadab460	9a4cae79-52d6-445a-8909-f16b5af0628b	Ambohitompoina	2026-08-26 20:04:05.949324+03	\N
47e7ef5f-9872-4b51-943f-f106712b551e	9a4cae79-52d6-445a-8909-f16b5af0628b	Ampitatafika	2026-08-26 20:04:05.949324+03	\N
2257d50f-8596-4acc-a3f4-a36073bc23e4	9a4cae79-52d6-445a-8909-f16b5af0628b	Andranofito	2026-08-26 20:04:05.949324+03	\N
e054a6c2-c61a-4d3d-8230-4534fca97839	9a4cae79-52d6-445a-8909-f16b5af0628b	Antanifotsy	2026-08-26 20:04:05.949324+03	\N
2f00c0ae-f9e2-4d87-826f-c8a21668a015	9a4cae79-52d6-445a-8909-f16b5af0628b	Antsahalava	2026-08-26 20:04:05.949324+03	\N
a4455764-092c-4fc4-be93-67bd314888b0	9a4cae79-52d6-445a-8909-f16b5af0628b	Antsampandrano	2026-08-26 20:04:05.949324+03	\N
752b9304-14e5-48a2-81c8-0c165c9e17fb	9a4cae79-52d6-445a-8909-f16b5af0628b	Belanitra	2026-08-26 20:04:05.949324+03	\N
4eaeac70-204f-46b0-a071-6add625ea435	9a4cae79-52d6-445a-8909-f16b5af0628b	Anjamanga	2026-08-26 20:04:05.949324+03	\N
66a06942-0f94-44d4-9478-714184346a2d	9a4cae79-52d6-445a-8909-f16b5af0628b	Soamanandrariny	2026-08-26 20:04:05.949324+03	\N
\.


--
-- Data for Name: contact_method; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.contact_method (id, person_id, type, is_verified, value, created_at, is_primary) FROM stdin;
0dc5fca3-122d-4303-9c4e-e7e289df7d19	ded0cc0d-e122-4d67-91db-84e605151982	email	t	sandaniainaadrien@gmail.com	2026-09-01 20:38:50.844047+03	t
83cc6292-abce-4bb7-8f1e-cdf3111196b9	9fe3017f-95f8-4f26-a4c8-933da500ba69	phone	f	+261341234567	2026-09-08 10:08:12.746+03	t
7d2eff4d-3fcf-429c-9933-6dfd0e662afd	9bb2173d-fb11-4fee-80fd-94ad22e4d17f	phone	f	+261341234567	2026-09-08 15:04:51.96+03	t
3800dac9-3aa8-4d87-8be5-03baa5705be0	944fdb6e-1783-4221-9c60-870699b1f059	phone	f	+261341234567	2026-09-08 15:07:10.488+03	t
6b98df69-f1b6-4973-a9b8-b45784ece26e	12e12741-5167-4052-863c-6ee3074aa7b0	phone	f	+261341234567	2026-09-08 15:09:17.054+03	t
b1884781-03b4-4072-8733-4d4720ba07df	c7e1b089-dedd-4586-b91a-88297d4df72b	phone	f	+261341234567	2026-09-08 18:19:13.351+03	t
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.country (id, iso2_code, iso3_code, name, nationality_name, created_at, updated_at) FROM stdin;
9d4a3e6b-4971-4baa-94ea-aa42489a2c54	MG	MDG	Madagascar	Malgache	2026-08-26 19:14:30.779364+03	\N
\.


--
-- Data for Name: district; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.district (id, region_id, name, created_at, updated_at) FROM stdin;
502119d5-b7be-4ab4-8363-e2c3df4778e8	3076cf18-3d40-4089-97ab-e1bc7ec20585	MANJAKANDRIANA	2026-08-26 19:29:49.288749+03	\N
05ca0b68-99ac-42de-a3c9-e523dc5cf1d6	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANTANANARIVO RENIVOHITRA	2026-08-26 19:29:49.288749+03	\N
4ff37ada-b76f-42ae-ac25-fcc50541832c	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANTANANARIVO AVARADRANO	2026-08-26 19:29:49.288749+03	\N
af85fdca-9a2f-440d-8a95-7b47e2510b4f	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANTANANARIVO ATSIMONDRANO	2026-08-26 19:29:49.288749+03	\N
2b8f5243-740b-4ace-92ce-739140990752	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANKAZOBE	2026-08-26 19:29:49.288749+03	\N
2e3d8852-88ab-4f51-aa03-71f16565d583	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANJOZOROBE	2026-08-26 19:29:49.288749+03	\N
b04d939c-8953-455c-af44-a2e483c7950e	3076cf18-3d40-4089-97ab-e1bc7ec20585	ANDRAMASINA	2026-08-26 19:29:49.288749+03	\N
0459f549-25ec-405f-8097-b1d4634e50fc	3076cf18-3d40-4089-97ab-e1bc7ec20585	AMBOHIDRATRIMO	2026-08-26 19:29:49.288749+03	\N
5dc1b9f5-f537-4383-8ece-d64ddd6147f0	53abeaf5-879d-48b8-88f7-d8744ae7da23	TSIROANOMANDIDY	2026-08-26 19:29:49.288749+03	\N
e1ab3513-b01d-4366-85e0-7cbba179b020	53abeaf5-879d-48b8-88f7-d8744ae7da23	FENOARIVOBE	2026-08-26 19:29:49.288749+03	\N
e52117d6-222f-4669-bff8-4d16edaea3e7	fa449858-0e93-40dc-82bf-6010a1b095c1	SOAVINANDRIANA	2026-08-26 19:29:49.288749+03	\N
022c3d66-8c0c-4821-a128-5b5fb4b4c0e2	fa449858-0e93-40dc-82bf-6010a1b095c1	MIARINARIVO	2026-08-26 19:29:49.288749+03	\N
caaa2d03-43fa-43fb-a01d-223c05025fff	fa449858-0e93-40dc-82bf-6010a1b095c1	ARIVONIMAMO	2026-08-26 19:29:49.288749+03	\N
3fd46d53-023e-4746-9f70-f420bfe4819f	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	MANDOTO	2026-08-26 19:29:49.288749+03	\N
5bdf9c58-e2f5-4a5e-973c-7df9777d32cb	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	FARATSIHO	2026-08-26 19:29:49.288749+03	\N
8b84612c-b4bb-437c-b652-6117e0d2a1d0	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	BETAFO	2026-08-26 19:29:49.288749+03	\N
b1c610e9-84a9-4722-b018-a3798e958b22	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	ANTSIRABE II	2026-08-26 19:29:49.288749+03	\N
bfaaa92b-d5ad-4d88-bfd1-d02c8c362304	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	ANTSIRABE I	2026-08-26 19:29:49.288749+03	\N
9a4cae79-52d6-445a-8909-f16b5af0628b	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	ANTANIFOTSY	2026-08-26 19:29:49.288749+03	\N
06597f99-5051-4398-99f6-3d186273f00f	600a3f29-9ad3-4e86-bdb8-d9e6971626a3	AMBATOLAMPY	2026-08-26 19:29:49.288749+03	\N
79b969d9-3e89-43d8-828e-f2d3bc96fc8b	dab45306-3057-49b9-97d9-d988b03a95ef	NOSY-BE	2026-08-26 19:29:49.288749+03	\N
be4b22a2-e3f0-4166-bfe6-d0f8336aa4b0	dab45306-3057-49b9-97d9-d988b03a95ef	ANTSIRANANA II	2026-08-26 19:29:49.288749+03	\N
5c9eb8ba-1e84-4e66-9f1e-7a68a3d414fb	dab45306-3057-49b9-97d9-d988b03a95ef	ANTSIRANANA I	2026-08-26 19:29:49.288749+03	\N
91f5470a-b0a3-4e8c-9177-2b51c5cd637b	dab45306-3057-49b9-97d9-d988b03a95ef	AMBILOBE	2026-08-26 19:29:49.288749+03	\N
75c3c6f0-4a7b-47a9-928e-de4d60ba9491	dab45306-3057-49b9-97d9-d988b03a95ef	AMBANJA	2026-08-26 19:29:49.288749+03	\N
5841a48c-c97c-4625-b5ec-2076649171e3	04566928-9320-43c9-b232-54ed425a6dd5	VOHEMAR	2026-08-26 19:29:49.288749+03	\N
104fc996-b7c5-44cd-b4d2-cdbb0d66bd52	04566928-9320-43c9-b232-54ed425a6dd5	SAMBAVA	2026-08-26 19:29:49.288749+03	\N
34f01204-23d2-49cb-9090-72c209b8c242	04566928-9320-43c9-b232-54ed425a6dd5	ANTALAHA	2026-08-26 19:29:49.288749+03	\N
f16f52ca-73f5-4f3e-9234-2bbdac8356ab	04566928-9320-43c9-b232-54ed425a6dd5	ANDAPA	2026-08-26 19:29:49.288749+03	\N
a406987a-61c9-4294-9662-40956096f382	af33442f-81de-4b16-be94-6828e7ccea13	MANANDRIANA	2026-08-26 19:29:49.288749+03	\N
ca5dd3e5-b49d-4d7a-a128-13707dc63875	af33442f-81de-4b16-be94-6828e7ccea13	FANDRIANA	2026-08-26 19:29:49.288749+03	\N
0aad86d1-fa64-4687-bd4d-37a9007e14a1	af33442f-81de-4b16-be94-6828e7ccea13	AMBOSITRA	2026-08-26 19:29:49.288749+03	\N
f4b0b9fe-838b-4574-baf3-3470143e05be	af33442f-81de-4b16-be94-6828e7ccea13	AMBATOFINANDRAHANA	2026-08-26 19:29:49.288749+03	\N
c205f9eb-670a-46b6-a495-ce59a4ac8c8b	570e1b05-c66a-42c9-a348-d49f82380c5e	LALANGINA	2026-08-26 19:29:49.288749+03	\N
e18deeb4-bb4e-46a5-8db0-da54a5b6e0bd	570e1b05-c66a-42c9-a348-d49f82380c5e	VOHIBATO	2026-08-26 19:29:49.288749+03	\N
d60fa8a1-dbf3-4dc1-9d37-674ebe5fa421	570e1b05-c66a-42c9-a348-d49f82380c5e	IKALAMAVONY	2026-08-26 19:29:49.288749+03	\N
fcffc4e3-daaf-46ef-bd3d-cc84e78aac88	570e1b05-c66a-42c9-a348-d49f82380c5e	ISANDRA	2026-08-26 19:29:49.288749+03	\N
d4809e7b-5faf-458b-bda3-67eb94cf9b9a	570e1b05-c66a-42c9-a348-d49f82380c5e	FIANARANTSOA	2026-08-26 19:29:49.288749+03	\N
170a3498-5a81-440d-8b49-fe7840bafaea	570e1b05-c66a-42c9-a348-d49f82380c5e	AMBOHIMAHASOA	2026-08-26 19:29:49.288749+03	\N
60d2df2e-0b6d-4fbe-b6c5-da13facfa7c0	570e1b05-c66a-42c9-a348-d49f82380c5e	AMBALAVAO	2026-08-26 19:29:49.288749+03	\N
eb17c56f-6e9b-410b-934c-2e93e1f5348f	ecf38f6c-6b69-447c-9b36-14ebd3c933a8	NOSY VARIKA	2026-08-26 19:29:49.288749+03	\N
9b9413b2-8cf8-4422-a2a0-21f69eba4813	ecf38f6c-6b69-447c-9b36-14ebd3c933a8	MANANJARY	2026-08-26 19:29:49.288749+03	\N
e23e24fe-ac89-4132-86c3-868938bee0c8	ecf38f6c-6b69-447c-9b36-14ebd3c933a8	IFANADIANA	2026-08-26 19:29:49.288749+03	\N
6c27a8dc-c23f-4ec9-b3c0-509017cf1939	c2c230e9-18a0-4659-ba08-587c3007884e	VOHIPENO	2026-08-26 19:29:49.288749+03	\N
9ec95983-a298-4a99-891d-78cba427ce8f	c2c230e9-18a0-4659-ba08-587c3007884e	MANAKARA	2026-08-26 19:29:49.288749+03	\N
c37b8629-ab6a-46d1-bbba-c8c8f6fa4d5c	c2c230e9-18a0-4659-ba08-587c3007884e	IKONGO	2026-08-26 19:29:49.288749+03	\N
b1607fba-9843-4f16-91a9-26292da8dc34	f4424d78-7e70-48ee-a7be-fda78ec7cb24	VONDROZO	2026-08-26 19:29:49.288749+03	\N
07b76986-174a-4bd3-ae43-fe3c0c03a146	f4424d78-7e70-48ee-a7be-fda78ec7cb24	VANGAINDRANO	2026-08-26 19:29:49.288749+03	\N
fc251c4f-0015-4c20-83d6-7f4f3667f10a	f4424d78-7e70-48ee-a7be-fda78ec7cb24	MIDONGY SUD	2026-08-26 19:29:49.288749+03	\N
511fb6d0-c956-4e86-a239-59f3fad98bcb	f4424d78-7e70-48ee-a7be-fda78ec7cb24	FARAFANGANA	2026-08-26 19:29:49.288749+03	\N
c50fa66b-1498-4363-853e-fe13c342261f	f4424d78-7e70-48ee-a7be-fda78ec7cb24	BEFOTAKA ATSIMO	2026-08-26 19:29:49.288749+03	\N
f1b0aae6-6cbb-49a7-808f-45ad78688869	9a8888a3-f7de-4e00-975c-25a241576be8	IVOHIBE	2026-08-26 19:29:49.288749+03	\N
ad9f1506-1333-4e8e-a7e9-bdc53e74e593	9a8888a3-f7de-4e00-975c-25a241576be8	IHOSY	2026-08-26 19:29:49.288749+03	\N
eaa383c7-9ddc-4280-94da-e90836775a96	9a8888a3-f7de-4e00-975c-25a241576be8	IAKORA	2026-08-26 19:29:49.288749+03	\N
d4060bb1-6ef7-4a52-a0e8-e50eabc26cce	f0503161-cff5-42ca-80d1-a9516d638679	MORONDAVA	2026-08-26 19:29:49.288749+03	\N
86e007ae-57be-42f7-955a-12806dbc538e	f0503161-cff5-42ca-80d1-a9516d638679	MIANDRIVAZO	2026-08-26 19:29:49.288749+03	\N
98f5afa3-0968-4ef0-b5e7-3c223b8a7869	f0503161-cff5-42ca-80d1-a9516d638679	MANJA	2026-08-26 19:29:49.288749+03	\N
d94f1675-2822-4437-b9a5-419ba1f08868	f0503161-cff5-42ca-80d1-a9516d638679	MAHABO	2026-08-26 19:29:49.288749+03	\N
f71c4a7e-7d7c-4fe8-8e33-6e9dcef024a1	f0503161-cff5-42ca-80d1-a9516d638679	BELO SUR TSIRIBIHINA	2026-08-26 19:29:49.288749+03	\N
c7dcf285-0539-45ba-a7b5-221f3539f3d0	25f9f103-2f56-4a78-9020-8559627f5595	TOLIARA II	2026-08-26 19:29:49.288749+03	\N
af4e015f-f57c-4e5b-ba67-86d0d6a21dd4	25f9f103-2f56-4a78-9020-8559627f5595	TOLIARA I	2026-08-26 19:29:49.288749+03	\N
e8c477e5-0699-4f9f-adcc-4558d6943cb2	25f9f103-2f56-4a78-9020-8559627f5595	SAKARAHA	2026-08-26 19:29:49.288749+03	\N
f213b3c6-ff98-4da8-a913-81eed2845dbc	25f9f103-2f56-4a78-9020-8559627f5595	MOROMBE	2026-08-26 19:29:49.288749+03	\N
dfcd7b20-eaef-4c72-becf-b41140406c29	25f9f103-2f56-4a78-9020-8559627f5595	BETIOKY SUD	2026-08-26 19:29:49.288749+03	\N
ca11a8d7-b37a-43bf-b9bd-2699829d1bed	25f9f103-2f56-4a78-9020-8559627f5595	BEROROHA	2026-08-26 19:29:49.288749+03	\N
c2e3b962-ef33-4a69-baa5-ad06a1d5edaf	25f9f103-2f56-4a78-9020-8559627f5595	BENENITRA	2026-08-26 19:29:49.288749+03	\N
602cf5cf-bb4c-4fc8-9770-4cc70a66954d	25f9f103-2f56-4a78-9020-8559627f5595	ANKAZOABO SUD	2026-08-26 19:29:49.288749+03	\N
4f6811e4-2c3b-4d1c-b62d-2be93143586c	25f9f103-2f56-4a78-9020-8559627f5595	AMPANIHY OUEST	2026-08-26 19:29:49.288749+03	\N
748ce6ea-c240-4d9a-b2c7-4a6cb0571cea	8c2c8276-1c02-410e-86cf-37352849d8fb	TSIHOMBE	2026-08-26 19:29:49.288749+03	\N
b110b8a7-dc78-4c1c-bea8-3ef5bf2907d7	8c2c8276-1c02-410e-86cf-37352849d8fb	BELOHA ANDROY	2026-08-26 19:29:49.288749+03	\N
32a98216-470b-4a88-9b3a-d3bdbd2fa9aa	8c2c8276-1c02-410e-86cf-37352849d8fb	BEKILY	2026-08-26 19:29:49.288749+03	\N
e9e95246-c18c-4965-9a47-e9131b9d3f3d	8c2c8276-1c02-410e-86cf-37352849d8fb	AMBOVOMBE ANDROY	2026-08-26 19:29:49.288749+03	\N
4513d662-f40e-4f65-9da4-c53e810b7e52	94c84bdd-d4ed-438c-b7c7-ac355c4fd011	TAOLANARO	2026-08-26 19:29:49.288749+03	\N
6b873dc3-d58a-44e5-9531-2ea9f7bb5074	94c84bdd-d4ed-438c-b7c7-ac355c4fd011	BETROKA	2026-08-26 19:29:49.288749+03	\N
0b8ec68d-a1a4-4dd1-9ea0-3eabc3f22a4d	94c84bdd-d4ed-438c-b7c7-ac355c4fd011	AMBOASARY SUD	2026-08-26 19:29:49.288749+03	\N
e2a17c11-299c-4052-b450-8494366f4dc6	7632eda7-b735-4b39-809c-c86b38aaad55	SOALALA	2026-08-26 19:29:49.288749+03	\N
cb8e699b-1d05-4e80-b876-e82d9a9b3006	7632eda7-b735-4b39-809c-c86b38aaad55	MITSINJO	2026-08-26 19:29:49.288749+03	\N
d586fe77-ea75-435b-b30d-e1a7deac62ad	7632eda7-b735-4b39-809c-c86b38aaad55	MAROVOAY	2026-08-26 19:29:49.288749+03	\N
03fc3d8b-c4c3-4ab9-8b33-b0a13584ecc4	7632eda7-b735-4b39-809c-c86b38aaad55	MAHAJANGA II	2026-08-26 19:29:49.288749+03	\N
f88628bf-c165-43c2-bbad-1d4494123ea3	7632eda7-b735-4b39-809c-c86b38aaad55	MAHAJANGA I	2026-08-26 19:29:49.288749+03	\N
75890aeb-0ff0-43d6-80e5-454f3c750444	7632eda7-b735-4b39-809c-c86b38aaad55	AMBATO BOENI	2026-08-26 19:29:49.288749+03	\N
9985c79c-60a3-4d19-b9b5-dc952fc16385	1888bb0b-ce79-493f-b02b-082b250086db	PORT-BERGE	2026-08-26 19:29:49.288749+03	\N
1ab9aa80-8def-493d-b19f-c1d2b06707ff	1888bb0b-ce79-493f-b02b-082b250086db	MANDRITSARA	2026-08-26 19:29:49.288749+03	\N
9ac5ca86-2aba-4e2e-b047-e557528e5caf	1888bb0b-ce79-493f-b02b-082b250086db	MAMPIKONY	2026-08-26 19:29:49.288749+03	\N
88dae594-154f-4818-ac19-d58e1beec645	1888bb0b-ce79-493f-b02b-082b250086db	BEFANDRIANA NORD	2026-08-26 19:29:49.288749+03	\N
c855422a-b912-48ac-b05a-9f3415710c7d	1888bb0b-ce79-493f-b02b-082b250086db	BEALANANA	2026-08-26 19:29:49.288749+03	\N
9ae83fa3-2596-4d63-b2be-ab02835b37b7	1888bb0b-ce79-493f-b02b-082b250086db	ANTSOHIHY	2026-08-26 19:29:49.288749+03	\N
55e8f047-3a2c-4a9a-984e-9cc4a60ea0c6	1888bb0b-ce79-493f-b02b-082b250086db	ANALALAVA	2026-08-26 19:29:49.288749+03	\N
dfa82898-18dd-40ed-8be7-97f214e54166	6c669eef-66d2-4579-9b90-f2598695ad45	TSARATANANA	2026-08-26 19:29:49.288749+03	\N
7bfb2ae1-a159-458f-9a50-83bdfda858bb	6c669eef-66d2-4579-9b90-f2598695ad45	MAEVATANANA	2026-08-26 19:29:49.288749+03	\N
45c57b33-feec-4bfa-8b23-0124f147a7e3	6c669eef-66d2-4579-9b90-f2598695ad45	KANDREHO	2026-08-26 19:29:49.288749+03	\N
8d1a609d-8230-4024-a7c4-03758cf9f398	179d9791-0b5c-41e6-a054-1e193d9a8807	MORAFENOBE	2026-08-26 19:29:49.288749+03	\N
85a771f5-3c43-4fb8-a546-b22ed2c63cf6	179d9791-0b5c-41e6-a054-1e193d9a8807	MAINTIRANO	2026-08-26 19:29:49.288749+03	\N
3a1829bc-bc9d-429c-9287-ec359646b3c7	179d9791-0b5c-41e6-a054-1e193d9a8807	BESALAMPY	2026-08-26 19:29:49.288749+03	\N
77bdd8b7-1547-4ed9-aaf5-05f4b8bcb9c8	179d9791-0b5c-41e6-a054-1e193d9a8807	ANTSALOVA	2026-08-26 19:29:49.288749+03	\N
9d771c44-714b-4637-974d-d542cb1eab78	179d9791-0b5c-41e6-a054-1e193d9a8807	AMBATOMAINTY	2026-08-26 19:29:49.288749+03	\N
e2efa207-61b2-4525-a9a7-ef070bb31f81	0a03339e-6539-47ff-a067-aaab3938b504	MORAMANGA	2026-08-26 19:29:49.288749+03	\N
9bf34f11-d2bb-40b6-84a1-6fa386b77029	0a03339e-6539-47ff-a067-aaab3938b504	ANOSIBE AN'ALA	2026-08-26 19:29:49.288749+03	\N
527d692e-cc51-4de7-9786-017ac06278d8	0a03339e-6539-47ff-a067-aaab3938b504	ANDILAMENA	2026-08-26 19:29:49.288749+03	\N
cedaaf51-6441-457c-97f4-af933c820730	0a03339e-6539-47ff-a067-aaab3938b504	AMPARAFARAVOLA	2026-08-26 19:29:49.288749+03	\N
6c8c8d7f-608a-4e9e-abba-2993ba160787	0a03339e-6539-47ff-a067-aaab3938b504	AMBATONDRAZAKA	2026-08-26 19:29:49.288749+03	\N
7bd83ce9-df66-46fe-b52b-288d9cc92517	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	VATOMANDRY	2026-08-26 19:29:49.288749+03	\N
f9479f66-1ce1-40ce-b155-9e5b79446bb5	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	TOAMASINA II	2026-08-26 19:29:49.288749+03	\N
6f75cc39-dde1-419d-8072-7d57ba851160	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	TOAMASINA I	2026-08-26 19:29:49.288749+03	\N
19fea0e4-13cc-4ad3-b1fc-bbfb621b2916	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	MAROLAMBO	2026-08-26 19:29:49.288749+03	\N
c09baabd-b84e-48b3-ae19-d4445f698cfe	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	MAHANORO	2026-08-26 19:29:49.288749+03	\N
628ff622-2201-4837-9621-e302b7a565d4	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	BRICKAVILLE	2026-08-26 19:29:49.288749+03	\N
64512599-4c78-4f66-8cd7-96d1e974cb3c	48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	ANTANAMBAO MANAMPONTSY	2026-08-26 19:29:49.288749+03	\N
c1dd42fa-e094-42ae-846d-37b9dc9f3743	19dde41a-0c2a-4663-89dc-ac453c63d8cb	VAVATENINA	2026-08-26 19:29:49.288749+03	\N
e7c2f4e9-8c40-489b-8266-80e2c3e498ff	19dde41a-0c2a-4663-89dc-ac453c63d8cb	SOANIERANA IVONGO	2026-08-26 19:29:49.288749+03	\N
51ea0b65-3238-4d6d-8e67-e2dba90939a2	19dde41a-0c2a-4663-89dc-ac453c63d8cb	SAINTE MARIE	2026-08-26 19:29:49.288749+03	\N
f9e27bcf-6d0a-4f9f-9b0e-0e118bfd6166	19dde41a-0c2a-4663-89dc-ac453c63d8cb	MAROANTSETRA	2026-08-26 19:29:49.288749+03	\N
a41f8250-70cb-47df-a538-4c49dcde1288	19dde41a-0c2a-4663-89dc-ac453c63d8cb	MANANARA-NORD	2026-08-26 19:29:49.288749+03	\N
d67415f0-5e7d-4691-8635-5b4ebd09e32a	19dde41a-0c2a-4663-89dc-ac453c63d8cb	FENERIVE EST	2026-08-26 19:29:49.288749+03	\N
\.


--
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.document (id, enrolment_id, document_type_id, front_file_path, back_file_path) FROM stdin;
c0015bd0-16a2-4c9f-926c-87464d216524	4fa5cd9f-13f8-46cf-8790-cba2ad195c5b	6851e3d4-ae17-4a93-a48e-1853a596367d	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png
d7a88b21-e96a-45ec-9e78-f78223ed3d5f	67930828-08db-4f92-a60a-0e12120e4ba5	6851e3d4-ae17-4a93-a48e-1853a596367d	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png
c84de0e9-5aed-49ca-90fa-d4d03b066659	cd34a49e-c7cc-4e2a-9763-142e39dfaeeb	6851e3d4-ae17-4a93-a48e-1853a596367d	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png
006912cc-3c4f-4fca-b0c4-f05ed48ab19d	a8fda6ab-bb74-4ea1-a2db-3c27cd457068	6851e3d4-ae17-4a93-a48e-1853a596367d	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png
4bd8e500-9e2d-40b5-9385-cb36b34dddec	26b5ffd1-1e67-4b5f-b789-a620f570d623	6851e3d4-ae17-4a93-a48e-1853a596367d	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png	/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png
\.


--
-- Data for Name: document_mrz; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.document_mrz (id, document_id, raw_mrz, processed_at) FROM stdin;
\.


--
-- Data for Name: document_ocr_result; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.document_ocr_result (id, document_id, engine_name, engine_version, extracted_text, confidence_score, processed_at) FROM stdin;
\.


--
-- Data for Name: document_type; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.document_type (id, name, description, evidence_strength, requires_mrz, supports_ocr, requires_original, created_at, updated_at) FROM stdin;
6851e3d4-ae17-4a93-a48e-1853a596367d	CIN	Carte d'Identité Nationale	SUPERIOR	f	t	t	2026-09-08 13:05:51.850607+03	\N
d597f726-6e21-40a6-b4c3-3391388ca78b	PASSPORT	Passeport	SUPERIOR	t	t	t	2026-09-08 13:05:51.850607+03	\N
1b78b862-745b-44d5-bc92-567ac49ecb37	DRIVING_LICENSE	Permis de conduire	FAIR	f	t	t	2026-09-08 13:05:51.850607+03	\N
eba1f2b3-93ca-4162-81cf-83c6819ad1ff	RESIDENCE_PERMIT	Carte de séjour	STRONG	f	t	t	2026-09-08 13:05:51.850607+03	\N
\.


--
-- Data for Name: enrolment; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.enrolment (id, agent_id, citizen_id, application_id, created_offline, sync_status, created_at, updated_at, enrolment_type) FROM stdin;
4fa5cd9f-13f8-46cf-8790-cba2ad195c5b	f47b953f-49ae-4c84-a8d7-38acc109cc8d	000c1869-dd9e-41e2-9f20-f557f4027220	APP-1788862092742-74094	f	f	2026-09-08 10:08:12.742+03	\N	NEW
67930828-08db-4f92-a60a-0e12120e4ba5	f47b953f-49ae-4c84-a8d7-38acc109cc8d	a5392cfd-006b-40dc-a554-7126ca68173c	APP-1788879891952-39031	f	f	2026-09-08 15:04:51.953+03	\N	NEW
cd34a49e-c7cc-4e2a-9763-142e39dfaeeb	f47b953f-49ae-4c84-a8d7-38acc109cc8d	851ff7ca-f044-4eed-8f90-56cac6fe308e	APP-1788880030485-87944	f	f	2026-09-08 15:07:10.486+03	\N	NEW
a8fda6ab-bb74-4ea1-a2db-3c27cd457068	f47b953f-49ae-4c84-a8d7-38acc109cc8d	8c17575a-dc9b-42b0-8f3a-cafaa6db8b6a	APP-1788880157052-45473	f	f	2026-09-08 15:09:17.052+03	\N	NEW
26b5ffd1-1e67-4b5f-b789-a620f570d623	f47b953f-49ae-4c84-a8d7-38acc109cc8d	e86b99d8-8025-4d95-8333-d64530ca2069	APP-1788891553112-66769	f	f	2026-09-08 18:19:13.115+03	\N	NEW
\.


--
-- Data for Name: face_biometrics; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.face_biometrics (id, enrolment_id, image_file_path, model_name, model_version, embeding, quality_score, face_detected, created_at, updated_at) FROM stdin;
328879ed-3bbc-4843-8c6f-780d47287b83	4fa5cd9f-13f8-46cf-8790-cba2ad195c5b	/uploads/faces/person.jpg	FaceNet	1.0.0	[0.123,0.456,0.789]	98.50	t	2026-09-08 10:08:12.755+03	\N
afdcafe4-0d6d-49f6-b5b8-593c9fb8bc77	67930828-08db-4f92-a60a-0e12120e4ba5	/uploads/faces/person.jpg	FaceNet	1.0.0	[0.123,0.456,0.789]	98.50	t	2026-09-08 15:04:51.974+03	\N
25a45274-860e-47a8-bb5f-0ef09019dd36	cd34a49e-c7cc-4e2a-9763-142e39dfaeeb	/uploads/faces/person.jpg	FaceNet	1.0.0	[0.123,0.456,0.789]	98.50	t	2026-09-08 15:07:10.493+03	\N
4bb988b2-03d1-47b3-84de-4778d9368217	a8fda6ab-bb74-4ea1-a2db-3c27cd457068	/uploads/faces/person.jpg	FaceNet	1.0.0	[0.123,0.456,0.789]	98.50	t	2026-09-08 15:09:17.06+03	\N
efce3ac0-4d0f-48e4-a263-aea08efc9d73	26b5ffd1-1e67-4b5f-b789-a620f570d623	/uploads/faces/person.jpg	FaceNet	1.0.0	[0.123,0.456,0.789]	98.50	t	2026-09-08 18:19:13.531+03	\N
\.


--
-- Data for Name: family_relationships; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.family_relationships (id, citizen_id, related_person_id, related_person_name, relationship_type) FROM stdin;
16a9ca7f-6fd2-4068-827e-ce4b17f5fed2	000c1869-dd9e-41e2-9f20-f557f4027220	\N	RAKOTO Jean	FATHER
8fa63962-bcc0-4317-b4ea-1386ceb1686e	a5392cfd-006b-40dc-a554-7126ca68173c	\N	RAKOTO Jean	FATHER
69dc8044-bfa1-4c00-8a5b-f5113fc586d8	851ff7ca-f044-4eed-8f90-56cac6fe308e	\N	Rakotomalala Jean	FATHER
22f0f74e-0692-42e0-849f-b0e51e5675fc	8c17575a-dc9b-42b0-8f3a-cafaa6db8b6a	\N	Rakotomalala1 Jean	FATHER
5471c39a-d4b8-4ecc-907b-2799f937434f	e86b99d8-8025-4d95-8333-d64530ca2069	\N	RAKOTO Jean	FATHER
\.


--
-- Data for Name: fokontany; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.fokontany (id, commune_id, name, created_at, updated_at) FROM stdin;
21d5b7d7-8820-4a8c-be92-91dfcf9e778e	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Vatovandana	2026-08-27 04:25:52.429434+03	\N
bfe31d2f-396b-4d1b-88f1-5fb08a04e953	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Soaloka	2026-08-27 04:25:52.429434+03	\N
33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Miaramasoandro	2026-08-27 04:25:52.429434+03	\N
5082b62d-24a5-4cb1-a0ec-e9886433f383	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Mahitsitady	2026-08-27 04:25:52.429434+03	\N
6f00e07c-99da-4c3e-9fab-5ceebee1e9b4	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Antsahalava	2026-08-27 04:25:52.429434+03	\N
d096dd50-0c25-4dab-b1fc-f84d5df0d79b	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Antanetibe	2026-08-27 04:25:52.429434+03	\N
8baba96d-7078-4105-acc7-314d81555b7e	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ankafotra	2026-08-27 04:25:52.429434+03	\N
a97eb48f-ad68-4a56-a41a-b82494f37ff7	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ankadibe	2026-08-27 04:25:52.429434+03	\N
63e5607f-225a-4d7b-9dce-331a00a2dc74	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ampanotokana	2026-08-27 04:25:52.429434+03	\N
25da4735-95df-4d8b-94b6-f4eb45725827	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambohimitsinjorano	2026-08-27 04:25:52.429434+03	\N
36bbaea3-84c6-4dce-8caa-d515158e2ea8	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambohijorery	2026-08-27 04:25:52.429434+03	\N
961725f9-6518-409f-bfde-e993a70c94fb	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambodimanga	2026-08-27 04:25:52.429434+03	\N
15b42b96-18ad-4d3f-92e3-fda3ff920c5d	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambatoharanana	2026-08-27 04:25:52.429434+03	\N
ecb34fbb-1c20-4b52-9f3e-76c9ed512a9f	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambato	2026-08-27 04:25:52.429434+03	\N
a4681c0c-a1fa-4d5b-a704-7e423b100bd4	8ec426c9-2ff1-4e80-850d-9c76cb176dec	Ambanimaso	2026-08-27 04:25:52.429434+03	\N
36069c86-06ec-4bf8-bbf1-74f779c0025a	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Tsinjoarivo	2026-08-27 04:25:52.429434+03	\N
66f1fdc6-e0f6-436d-9a9d-fa879b2bad42	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Morarano	2026-08-27 04:25:52.429434+03	\N
5ba36749-fe98-4451-9f0c-eb36a524ca8c	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Manjakatompo	2026-08-27 04:25:52.429434+03	\N
afb2de62-e992-4894-88c9-49c4559c73bf	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Behenjy	2026-08-27 04:25:52.429434+03	\N
71a8518a-97fa-4143-9fc3-45b9455707ab	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Antsampandrano	2026-08-27 04:25:52.429434+03	\N
0ec1e9be-8e40-47e4-b7ae-384e9c9d301b	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Antakasina	2026-08-27 04:25:52.429434+03	\N
813057a8-5415-45ec-90f5-a4f8d2af7ae2	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Andriambilany	2026-08-27 04:25:52.429434+03	\N
4c49deb4-1a5a-45dd-87ec-b623acf4bd17	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Andranovelona	2026-08-27 04:25:52.429434+03	\N
d45aedee-1dec-41eb-890b-a59291942e38	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambatolampy Centre	2026-08-27 04:25:52.429434+03	\N
f9332f1c-4561-4499-9149-7c3b1c0cb75b	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
89656309-24e5-4dd4-b548-c15cb75fe59a	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Soavinarivo	2026-08-27 04:25:52.429434+03	\N
6ed3892d-fc08-4354-956d-22366d433d5a	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Avarajozoro	2026-08-27 04:25:52.429434+03	\N
206ebc77-2eb8-4f2b-902e-571bd06e204f	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Anjomakely	2026-08-27 04:25:52.429434+03	\N
efd9d13d-95b0-4dd3-a946-468c7fff1427	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambohinome	2026-08-27 04:25:52.429434+03	\N
12780335-23ce-4116-ac9a-6ed09cf45fea	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambohimarina	2026-08-27 04:25:52.429434+03	\N
c29611d0-f2ae-42d1-9807-6efd67fb4da1	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambohidava	2026-08-27 04:25:52.429434+03	\N
eb1d5bf2-3669-47f7-9a1c-7c33df8ecd54	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambodifasina	2026-08-27 04:25:52.429434+03	\N
85355dc7-cb63-4257-8c08-608fc1db1281	efd44d55-42a9-48fe-b7df-4a529c6e6ff4	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
141bda97-db09-4ccf-9788-8eb46982c2cd	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Morondava	2026-08-27 04:25:52.429434+03	\N
b1b9f386-d3bb-4090-8763-9a67de382fd8	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Antsakambahiny	2026-08-27 04:25:52.429434+03	\N
59713226-b1e5-47e9-a609-bc11cc88fc0e	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Antanetibe	2026-08-27 04:25:52.429434+03	\N
e5f7a46e-84c8-4997-8b3a-31fab0f72d64	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Antalamohitra	2026-08-27 04:25:52.429434+03	\N
184d9126-7788-44b2-993a-2aa811de6d94	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Ankadivory	2026-08-27 04:25:52.429434+03	\N
fc9e8aa6-306e-40e2-b1b0-d2d2bb79830c	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Andranoro	2026-08-27 04:25:52.429434+03	\N
a0ce4971-139e-450f-a313-b375dc937f85	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Ambohijanahary	2026-08-27 04:25:52.429434+03	\N
36267d3f-3f44-4a66-aad9-c63f7aec2d41	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Ambohibao	2026-08-27 04:25:52.429434+03	\N
47365aab-0b29-4421-bd81-6ecfcc2e5f88	80ff7643-e4f4-4cc2-8256-7a819a0524ae	Amboaroy	2026-08-27 04:25:52.429434+03	\N
273e8ea8-b35b-409e-bcda-a45ff160b8b7	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Soamananety	2026-08-27 04:25:52.429434+03	\N
caca2421-3f63-47b0-915b-15d84d2fbd59	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Antsimomparihy	2026-08-27 04:25:52.429434+03	\N
b6412107-69a7-4b25-a2dc-bd456325ad90	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Antohibe	2026-08-27 04:25:52.429434+03	\N
5b7c1ac6-1648-4065-8728-188e2c30f1b7	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ampanataovana	2026-08-27 04:25:52.429434+03	\N
5797b554-17d4-4bba-9063-b046211bd26e	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ambovo	2026-08-27 04:25:52.429434+03	\N
d860a671-f0a2-439b-8077-79d821aa8087	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ambohitsiroa Est	2026-08-27 04:25:52.429434+03	\N
2b9e4eae-6140-4e32-b4ed-3d123ecc8a66	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ambohidratrimo	2026-08-27 04:25:52.429434+03	\N
d244101f-cafb-4ee0-9160-33a9d75b8382	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ambodisaha	2026-08-27 04:25:52.429434+03	\N
a176a5ba-a9c0-4a93-a50d-265c0f989cb6	b88675b5-4155-475e-a0c1-e2cf56ee45b3	Ambodehilahy	2026-08-27 04:25:52.429434+03	\N
d75424ed-5010-4dfb-ae02-2f9d5daae9fd	65e120ad-578c-47e9-a2f2-2d432aa2759b	Ankondodona	2026-08-27 04:25:52.429434+03	\N
daef081e-d504-43a1-ba14-d172a42a3dba	65e120ad-578c-47e9-a2f2-2d432aa2759b	Anjehivola	2026-08-27 04:25:52.429434+03	\N
125f7f41-b513-45a8-94bf-0d0c8547a1ec	65e120ad-578c-47e9-a2f2-2d432aa2759b	Andranomasina	2026-08-27 04:25:52.429434+03	\N
cf9d6c54-37ad-464f-aa90-2c898782b2d6	65e120ad-578c-47e9-a2f2-2d432aa2759b	Ambohitrinibe	2026-08-27 04:25:52.429434+03	\N
1629b1f2-faaf-4a82-a42d-7fb5a26b945e	65e120ad-578c-47e9-a2f2-2d432aa2759b	Ambohimarina ouest	2026-08-27 04:25:52.429434+03	\N
51aacf2e-b4c1-47ed-83e1-030728ee9844	65e120ad-578c-47e9-a2f2-2d432aa2759b	Ambohimanjaka	2026-08-27 04:25:52.429434+03	\N
ce413c04-3bbb-4ae5-8b3e-8554749b6762	65e120ad-578c-47e9-a2f2-2d432aa2759b	Ambohidrazaka	2026-08-27 04:25:52.429434+03	\N
e908e170-cba8-4e12-a684-a06261bb9613	8f4e5fc4-cb9e-45e3-9520-c2a8a6875c27	Tsarahonenana	2026-08-27 04:25:52.429434+03	\N
1bb89a59-0162-4d08-8bfa-adfe44a0dc6d	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Ifarihy	2026-08-27 04:25:52.429434+03	\N
ba8d78e1-00f2-40d3-a999-13246fdb18e7	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Ankadinandriana	2026-08-27 04:25:52.429434+03	\N
3112218e-309d-4a1a-906b-6887203e3176	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Ambohibahiny	2026-08-27 04:25:52.429434+03	\N
f7c1500d-48f8-404b-87e8-c99ca111df9c	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Ambodivoanjo	2026-08-27 04:25:52.429434+03	\N
70799d6a-aa0f-42c6-bedb-3b22310127ab	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Antanetisoa	2026-08-27 04:25:52.429434+03	\N
511da3d0-c2f6-404a-930a-e1f7644bc52f	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Antsahasoa	2026-08-27 04:25:52.429434+03	\N
0473f703-aa12-48b3-8f9b-0c0dcdbeea96	ca25900e-5978-4695-8d9d-34d68fb0c5d2	Ankadilalampotsy	2026-08-27 04:25:52.429434+03	\N
30b6dd68-0648-48b0-a016-7472fe50c525	1df37f7a-34e9-40de-a41d-fb071e74ab86	Antsahakely	2026-08-27 04:25:52.429434+03	\N
a4524270-0180-49f2-b54b-f75e5845f724	1df37f7a-34e9-40de-a41d-fb071e74ab86	Anosivita Boina	2026-08-27 04:25:52.429434+03	\N
f7f10ca9-8d75-45b9-910a-2e9a522460fa	1df37f7a-34e9-40de-a41d-fb071e74ab86	Andranovaky	2026-08-27 04:25:52.429434+03	\N
d9f565aa-1f80-4dcf-b687-df518adb7cdb	37833d1a-fb61-47c9-bf07-93a4c1083e44	Vatovaky	2026-08-27 04:25:52.429434+03	\N
14ce4ed3-a096-4d32-bd83-3844ab3317da	37833d1a-fb61-47c9-bf07-93a4c1083e44	Tsiafahy	2026-08-27 04:25:52.429434+03	\N
e150713b-22b9-4d0b-b8eb-7456ce67b40b	37833d1a-fb61-47c9-bf07-93a4c1083e44	Soavina	2026-08-27 04:25:52.429434+03	\N
2f593633-d11d-4cd7-9591-735e4f160f3d	37833d1a-fb61-47c9-bf07-93a4c1083e44	Soamanandray	2026-08-27 04:25:52.429434+03	\N
9f3c6260-6a86-44c8-b1c4-03387df0f85e	37833d1a-fb61-47c9-bf07-93a4c1083e44	Masomboay	2026-08-27 04:25:52.429434+03	\N
18c14287-5ac8-487f-8e46-bbe59d629994	37833d1a-fb61-47c9-bf07-93a4c1083e44	Avarabohitra	2026-08-27 04:25:52.429434+03	\N
06ef230c-ca39-449e-94b1-bda84e25d1a1	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ankorondrano	2026-08-27 04:25:52.429434+03	\N
576574b2-c1bd-42da-942a-7b7f9fcefab6	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ankazobe	2026-08-27 04:25:52.429434+03	\N
1552a188-c0a8-493f-a143-3fe59575d055	37833d1a-fb61-47c9-bf07-93a4c1083e44	Andrefandrano	2026-08-27 04:25:52.429434+03	\N
09d2d359-bf4e-417a-a18d-1af68412cb97	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambohimiadana Nord	2026-08-27 04:25:52.429434+03	\N
5deaf345-fbf7-497a-a706-d12b222e3e49	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambohikely	2026-08-27 04:25:52.429434+03	\N
e4746ec6-c4e2-47a7-8330-b9b731b3c993	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambohibololona	2026-08-27 04:25:52.429434+03	\N
0b226dd7-759a-4e56-94b1-c61ec642d0da	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambohaja	2026-08-27 04:25:52.429434+03	\N
5521edf3-877d-48e9-a26f-f16307e25c9a	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambatofotsy	2026-08-27 04:25:52.429434+03	\N
03f91b87-ee25-42ef-a620-b2bf1b081996	37833d1a-fb61-47c9-bf07-93a4c1083e44	Ambatolokanga	2026-08-27 04:25:52.429434+03	\N
059dc71e-9417-4545-8b97-6c79b990f980	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Andrononobe	2026-08-27 04:25:52.429434+03	\N
6442c4c9-bab3-4495-a56c-b284d6d3fb59	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Manazary	2026-08-27 04:25:52.429434+03	\N
4fbf039a-a49a-41fe-8f09-5697068ae827	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Ambohitrarahaba	2026-08-27 04:25:52.429434+03	\N
68e41a7e-f40d-426b-a3c7-dcb92d257952	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Andafiavaratra	2026-08-27 04:25:52.429434+03	\N
e158522f-28c2-4d16-8d04-002883b7e43f	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Manjaka	2026-08-27 04:25:52.429434+03	\N
77f0cf0d-d2c4-4dc5-b8cc-57e3d25bb561	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Ilafy	2026-08-27 04:25:52.429434+03	\N
3c04b4c7-0279-4fd1-a9f6-97e715fc218a	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Antanandrano	2026-08-27 04:25:52.429434+03	\N
6f68faa2-5e7f-4b6a-82c5-57a6e6f80c21	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Antsampandrano	2026-08-27 04:25:52.429434+03	\N
2f417338-2f6e-458f-9a68-c8aaf5318941	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Belanitra	2026-08-27 04:25:52.429434+03	\N
8d1b3069-afe3-4b15-b087-05354dd775e9	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Ambohitraina	2026-08-27 04:25:52.429434+03	\N
2af54a20-0623-481d-b6d2-05c99867ebb6	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Ambohipanja	2026-08-27 04:25:52.429434+03	\N
5c52ab3d-ef15-460c-9605-45877779b540	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Andranovelona	2026-08-27 04:25:52.429434+03	\N
5b2beb6c-9b32-4632-a2a1-c09307bb9f79	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Antsahamarofoza	2026-08-27 04:25:52.429434+03	\N
72655a56-acf5-4a3c-9491-cb3a064abb38	00015f0f-ecb2-499c-afe4-3caf7ebb8639	Ankadikely	2026-08-27 04:25:52.429434+03	\N
43f9cc3c-ae15-482d-a247-4c6e00f6f036	414fdd7d-f545-4ab0-810f-037c476731ca	Analamahitsy Tanana	2026-08-27 04:25:52.429434+03	\N
92362239-7ad3-4739-befe-71f50e2c36e3	414fdd7d-f545-4ab0-810f-037c476731ca	Analamahitsy Cité	2026-08-27 04:25:52.429434+03	\N
b59c1060-04d3-46c0-b74c-737ced4aedb8	414fdd7d-f545-4ab0-810f-037c476731ca	Ambodivoanjo Ambohijatovo Fara	2026-08-27 04:25:52.429434+03	\N
55b27ee4-a901-4e71-8366-8b4f8d930771	414fdd7d-f545-4ab0-810f-037c476731ca	Ivandry	2026-08-27 04:25:52.429434+03	\N
9eb8c1bc-aa28-44ae-adf5-e3599e3c7b80	414fdd7d-f545-4ab0-810f-037c476731ca	Alarobia Amboniloha	2026-08-27 04:25:52.429434+03	\N
e3cbfaa2-677b-4a00-9540-b7783b45d3f0	414fdd7d-f545-4ab0-810f-037c476731ca	Androhibe	2026-08-27 04:25:52.429434+03	\N
116f060c-bb4c-453d-867b-636e2362bb47	414fdd7d-f545-4ab0-810f-037c476731ca	Soavimasoandro	2026-08-27 04:25:52.429434+03	\N
38c5f7d0-e974-4dfc-aa33-6fd1029ba6a4	eb041046-3ea4-4c57-b640-3fae715250b5	Sambaina	2026-08-27 04:25:52.429434+03	\N
9989b034-329c-45b0-8bb3-cf2c8fc46fc4	eb041046-3ea4-4c57-b640-3fae715250b5	Sadabe	2026-08-27 04:25:52.429434+03	\N
c2c7c7f2-d1f4-41f8-a80e-18c4c8f0433f	eb041046-3ea4-4c57-b640-3fae715250b5	Mantasoa	2026-08-27 04:25:52.429434+03	\N
965e3194-96fc-4805-94fa-d73d06e3b52c	eb041046-3ea4-4c57-b640-3fae715250b5	Ambohibary	2026-08-27 04:25:52.429434+03	\N
dc164187-5e1f-4902-aeed-e9e65ef2c65f	eb041046-3ea4-4c57-b640-3fae715250b5	Ambatomanga	2026-08-27 04:25:52.429434+03	\N
6e120f12-e685-48c9-bf7d-a185044c0980	eb041046-3ea4-4c57-b640-3fae715250b5	Ambatomena	2026-08-27 04:25:52.429434+03	\N
7aed6fee-9131-4ecb-bc3d-c47d6b708f21	eb041046-3ea4-4c57-b640-3fae715250b5	Manjakandriana	2026-08-27 04:25:52.429434+03	\N
2b9784bc-474e-4991-9262-228dd800c3eb	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Tsinjoarivo	2026-08-27 04:25:52.429434+03	\N
faa42c73-06a2-477c-9822-2f7be36fc189	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Morarano	2026-08-27 04:25:52.429434+03	\N
39a07bad-ff52-4d73-8359-221f4de51fc6	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Manjakatompo	2026-08-27 04:25:52.429434+03	\N
92cec8ae-ab21-459e-8246-6d19e74c24e5	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Behenjy	2026-08-27 04:25:52.429434+03	\N
dff4e855-936f-47d2-bcef-f18be31f7a5a	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Antsampandrano	2026-08-27 04:25:52.429434+03	\N
46aa5e3d-c34e-425e-a577-1939a671cee1	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Antakasina	2026-08-27 04:25:52.429434+03	\N
cc075575-74d8-40be-9b95-94cb25ac34f5	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Andriambilany	2026-08-27 04:25:52.429434+03	\N
b4e333fc-94db-4179-a1b6-2ae5d2074a19	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Andranovelona	2026-08-27 04:25:52.429434+03	\N
4d855d69-aa1e-4144-9159-41b7bde3b42c	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambatolampy Centre	2026-08-27 04:25:52.429434+03	\N
e038d03c-6f2f-4f82-89d1-fc6748ed73e1	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
714deb81-7ca4-4da3-9bf4-131ea0e56938	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Soavinarivo	2026-08-27 04:25:52.429434+03	\N
411a4788-bc3c-4ec7-a2d5-471a7e6becf9	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Avarajozoro	2026-08-27 04:25:52.429434+03	\N
dba36a79-66bd-4b7b-88fc-1f9f0348a091	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Anjomakely	2026-08-27 04:25:52.429434+03	\N
8d368abd-a0cc-4414-8544-d693d16c40cd	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambohinome	2026-08-27 04:25:52.429434+03	\N
1929d699-3e35-498b-a4f7-891a88d3c25f	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambohimarina	2026-08-27 04:25:52.429434+03	\N
4f9f8900-bd74-405d-b6bb-2801a158b9d0	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambohidava	2026-08-27 04:25:52.429434+03	\N
b350d69f-9252-4161-a1b9-812c44f115a5	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambodifasina	2026-08-27 04:25:52.429434+03	\N
31918101-7288-47f6-b798-f5d6284f756b	dc9c34cb-ca0e-40e6-ae6c-c80e7abc800c	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
841d6094-64f6-4c10-a118-59ffa3bfdcf2	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Tsinjoarivo	2026-08-27 04:25:52.429434+03	\N
e8509889-5e79-4f5c-b7e5-08390e9e7189	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Morarano	2026-08-27 04:25:52.429434+03	\N
f2d0e54f-18d2-4a76-82f5-c6a057dc66ba	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Manjakatompo	2026-08-27 04:25:52.429434+03	\N
52f350be-af69-4a6b-9048-fe15d6aa7600	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Behenjy	2026-08-27 04:25:52.429434+03	\N
538eecf4-a740-4526-92e6-4f1e7d1dad8e	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Antsampandrano	2026-08-27 04:25:52.429434+03	\N
0dda0bcf-17e8-47eb-a99a-e88f753aec65	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Antakasina	2026-08-27 04:25:52.429434+03	\N
a9ce20ee-c4b7-497b-bf6a-86a8cfabe157	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Andriambilany	2026-08-27 04:25:52.429434+03	\N
75a71249-530c-48a9-9617-7364a0836b7e	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Andranovelona	2026-08-27 04:25:52.429434+03	\N
a1ef8b8c-3606-4e16-a40a-b78225066ef9	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambatolampy Centre	2026-08-27 04:25:52.429434+03	\N
e636adcb-eb75-4db7-9b7c-bd6486295ba9	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
83b32ecf-f886-4795-ac4b-52cb51775183	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Soavinarivo	2026-08-27 04:25:52.429434+03	\N
ef127f3f-f50f-46c7-ba4e-47481e90f91f	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Avarajozoro	2026-08-27 04:25:52.429434+03	\N
ee918859-6da4-44c8-a66e-44d7bb95c001	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Anjomakely	2026-08-27 04:25:52.429434+03	\N
6371b702-6bb7-4348-ab06-6914dd07b191	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambohinome	2026-08-27 04:25:52.429434+03	\N
ab973aaa-a906-4834-9b4f-e15301826524	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambohimarina	2026-08-27 04:25:52.429434+03	\N
e894f83c-f674-4c63-8f5b-4614cad49051	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambohidava	2026-08-27 04:25:52.429434+03	\N
876c5db0-f295-47ef-ad44-192f2e0341a7	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambodifasina	2026-08-27 04:25:52.429434+03	\N
4d1cbc1e-59c2-4f32-bd02-df2be86113e5	6528bc3d-3e2b-43ec-b36b-7d52e938d63b	Ambatolampy	2026-08-27 04:25:52.429434+03	\N
1e52ea38-9d71-4477-88f4-bf715f8b4d68	e054a6c2-c61a-4d3d-8230-4534fca97839	Antsampandrano	2026-08-27 04:25:52.429434+03	\N
e16cc7fc-3a72-4240-9760-ab5bbef77f4c	e054a6c2-c61a-4d3d-8230-4534fca97839	Antsahalava	2026-08-27 04:25:52.429434+03	\N
e8e7ff6d-47b6-4e46-b021-5ee7acb7262b	e054a6c2-c61a-4d3d-8230-4534fca97839	Andranofito	2026-08-27 04:25:52.429434+03	\N
a75e32c1-404e-4467-a968-5ed8ddc35dab	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambohitompoina	2026-08-27 04:25:52.429434+03	\N
6a6116c9-74ec-4ae4-a83d-50f1ad94d5de	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambohimandroso	2026-08-27 04:25:52.429434+03	\N
d581164d-1966-40cd-b21a-ef10135a41d8	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambodiriana	2026-08-27 04:25:52.429434+03	\N
16c1ad5a-8db4-44e6-a5a4-dea40eba1d89	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambatotsipihana	2026-08-27 04:25:52.429434+03	\N
a8eed847-830c-418c-a876-d58a111580e4	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambatomiady	2026-08-27 04:25:52.429434+03	\N
524182ca-fc37-4537-a7f5-50e6fcd4545e	e054a6c2-c61a-4d3d-8230-4534fca97839	Ambatolahy	2026-08-27 04:25:52.429434+03	\N
68166865-536f-429c-a3d9-6012ba176150	e054a6c2-c61a-4d3d-8230-4534fca97839	Antanifotsy	2026-08-27 04:25:52.429434+03	\N
\.


--
-- Data for Name: password_reset_otp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_otp (id, agent_id, otp_hash, expires_at, attempts, used_at, created_at) FROM stdin;
4ef3ca80-1bd8-4b0d-bc2b-de1964e66df8	f47b953f-49ae-4c84-a8d7-38acc109cc8d	e78c8b9410496c933fdc701b91ac2d09ef7b7a0729c80c46064674f3bb96b2a7	2026-09-01 17:50:02.299+03	0	2026-09-01 17:42:52.754+03	2026-09-01 17:40:02.303+03
8ae6ab45-9d6b-48e0-affb-793130933f8d	f47b953f-49ae-4c84-a8d7-38acc109cc8d	bfac6fb73843e4e9853973c50623e2ca51356b2b508f1c4bfccfc5f9672991c5	2026-09-01 17:52:52.793+03	0	2026-09-01 17:43:45.664+03	2026-09-01 17:42:52.797+03
285e97e4-ab99-4cbf-b077-6d6489c65635	f47b953f-49ae-4c84-a8d7-38acc109cc8d	714724a7f852ae0231da5f806b1a9f8aeb8f6905d176d0f87988163fe7b01782	2026-09-01 17:59:05.599+03	0	2026-09-01 17:49:20.572+03	2026-09-01 17:49:05.603+03
bbe5057e-3b7e-44f4-8355-4eaea2ed0975	f47b953f-49ae-4c84-a8d7-38acc109cc8d	dab59b75a68afb57647ba1f4eee53629be24fa4de58c6c8f1cf1cc18350b531b	2026-09-01 18:51:33.02+03	0	\N	2026-09-01 18:41:33.025+03
\.


--
-- Data for Name: password_reset_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_token (id, agent_id, token_hash, expires_at, used_at, created_at) FROM stdin;
bb04b05f-f268-4b05-8b30-3ad9accd0365	f47b953f-49ae-4c84-a8d7-38acc109cc8d	be63767e631c60eb2d84df7547e907543f160e9db4cebbad35243877c91facea	2026-09-01 17:53:45.773+03	2026-09-01 17:44:18.869+03	2026-09-01 17:43:45.777+03
bb41d47c-3109-47d3-b34f-d73f0d3a58b8	f47b953f-49ae-4c84-a8d7-38acc109cc8d	ac5dc4b1b37a238a5b6f31f22252dc0107321be0651d9fdbb1fea1c3cd8b0366	2026-09-01 17:59:20.697+03	2026-09-01 17:49:45.057+03	2026-09-01 17:49:20.7+03
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.person (id, first_name, last_name, date_of_birth, birth_place, id_country_of_birth, sex, created_at, updated_at, date_of_death) FROM stdin;
6ee6518c-99ea-4594-ac71-fd2df5d5d975	Jean	RAKOTO	1990-05-12	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-08-27 04:35:39.733588+03	\N	\N
ded0cc0d-e122-4d67-91db-84e605151982	Marie	RABE	1988-11-03	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	F	2026-08-27 04:35:39.733588+03	\N	\N
e702fb40-606b-44b6-88b6-cd30d2917fea	Andry	RANDRIAMBOLOLONA	1992-02-18	Antsirabe	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-08-27 04:35:39.733588+03	\N	\N
3b26d0e2-c051-4ab0-9967-1803b91a367d	Fara	RAKOTONDRABE	1995-08-27	Fianarantsoa	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	F	2026-08-27 04:35:39.733588+03	\N	\N
9fe3017f-95f8-4f26-a4c8-933da500ba69	Jean	RAKOTO	1995-06-15	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-09-08 10:08:12.738+03	\N	\N
9bb2173d-fb11-4fee-80fd-94ad22e4d17f	Jean	RAKOTO	1995-06-15	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-09-08 15:04:51.949+03	\N	\N
944fdb6e-1783-4221-9c60-870699b1f059	Jean	Rakotomalala	1995-06-15	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-09-08 15:07:10.483+03	\N	\N
12e12741-5167-4052-863c-6ee3074aa7b0	Jean	Rakotomalala1	1995-06-15	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-09-08 15:09:17.049+03	\N	\N
c7e1b089-dedd-4586-b91a-88297d4df72b	Jean	RAKOTO	1995-06-15	Antananarivo	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	M	2026-09-08 18:19:13.016+03	\N	\N
\.


--
-- Data for Name: refresh_token; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_token (id, agent_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
cb9fa580-e7a6-4dfd-9a2c-32d91c9579a0	4257f270-d0f4-4ad4-a530-32612cb7113e	07cf685d88cb759d5bb63376d747aae5e63ac857973a582fd6b40d417b67daf4	2026-09-07 13:05:47.639+03	2026-08-31 13:06:14.67+03	2026-08-31 13:05:47.646+03
c3b173b5-1dad-4206-be4d-c39a6c3251ad	4257f270-d0f4-4ad4-a530-32612cb7113e	289702ebf7029dda274dba47aad4511d8cd3c52a4857f8525d883a329c3f8f29	2026-09-07 07:33:40.42+03	2026-08-31 13:14:18.251+03	2026-08-31 07:33:40.427+03
a6a4b968-0264-45e0-980c-2928167cf542	4257f270-d0f4-4ad4-a530-32612cb7113e	b0db70015fd749aed6efb9e26eaddd9a6d15c2317448eb74d50b4f4e8ee35cf1	2026-09-07 12:59:06.767+03	2026-08-31 13:14:18.251+03	2026-08-31 12:59:06.773+03
eac3f4ba-ceda-4960-81d8-b1ef20544b96	4257f270-d0f4-4ad4-a530-32612cb7113e	4bfe2908f6d93a1ad5faacb7e81f0029fe5fa5ac2e08a9be3baa2efff48b818b	2026-09-07 13:00:02.393+03	2026-08-31 13:14:18.251+03	2026-08-31 13:00:02.393+03
d52d17a4-8ce5-4989-8e63-e71fbd5def0d	4257f270-d0f4-4ad4-a530-32612cb7113e	7b0a35eb2d701048fa4c2577f027126479a98116cff3f513f36c554d0cee3189	2026-09-07 13:13:31.483+03	2026-08-31 13:14:18.251+03	2026-08-31 13:13:31.489+03
8bf963fa-fc32-45da-8308-ec73143fa8e0	4257f270-d0f4-4ad4-a530-32612cb7113e	d1fcd6414ad22a0c90c62e4ab8ab434570490af7df6307f46ac7b6cf4abe0a5e	2026-09-07 13:35:40.778+03	2026-08-31 13:36:23.318+03	2026-08-31 13:35:40.786+03
e4a3ea03-8f64-4534-a90c-e5c37ff6a6cb	4257f270-d0f4-4ad4-a530-32612cb7113e	201550b09b017f0dc94eb3f785f5a7bdd0406803e0e5c3bf4700b3608f08000b	2026-09-07 13:39:08.174+03	2026-08-31 13:42:04.904+03	2026-08-31 13:39:08.175+03
758a77fa-2a1e-4ce9-8ad6-987f6248c7ee	4257f270-d0f4-4ad4-a530-32612cb7113e	fb5226163d5f1888fbaae2bc5b84a1d216b118e88ced07745fcdca37b2eecc7a	2026-09-07 13:39:23.403+03	2026-08-31 13:42:04.904+03	2026-08-31 13:39:23.403+03
bd2fbbe5-97b9-4de2-a0eb-628175177a38	4257f270-d0f4-4ad4-a530-32612cb7113e	d23538a1e598a1bef0375dea699ef3acc90cca9e2d5393ec40e316e4f8f0f566	2026-09-07 13:40:59.275+03	2026-08-31 13:42:04.904+03	2026-08-31 13:40:59.283+03
cc59edea-8059-4add-864d-1b99ccdb741f	4257f270-d0f4-4ad4-a530-32612cb7113e	0ad767db9f150ff3030ec2f36054b90fbc7aa2f70f5f43cff1264d792aff9932	2026-09-07 13:56:06.728+03	\N	2026-08-31 13:56:06.736+03
5e88ffcb-4638-4619-a739-70b7305f1c9a	4257f270-d0f4-4ad4-a530-32612cb7113e	fc016476a1b335154b69b38e40811d06c44fe03e47d510b325279af24f9dd2e4	2026-09-08 17:45:07.416+03	\N	2026-09-01 17:45:07.417+03
d1758e22-6eb0-4973-a112-61459a0a90b5	4257f270-d0f4-4ad4-a530-32612cb7113e	3ddfe1d6bef640d4aff11b60e0c9b6c757e757588197dc93894368a367bbf29d	2026-09-08 17:49:59.754+03	\N	2026-09-01 17:49:59.755+03
fc41e881-4ac2-4c2c-acb0-8c468220c3b3	f47b953f-49ae-4c84-a8d7-38acc109cc8d	cc8609b79388ea24a5a66e0befc8848a0a294acca921394f0ee77602e1dc6b15	2026-09-15 08:44:09.022+03	2026-09-08 08:44:21.376+03	2026-09-08 08:44:09.022+03
d44702cd-d023-4629-b453-0eb3448d1cb7	f47b953f-49ae-4c84-a8d7-38acc109cc8d	38378a2ec93517d3b411daf4f4be3bc842797da2ed979cb73013ff95bc3d909b	2026-09-08 17:52:07.715+03	2026-09-08 18:14:16.325+03	2026-09-01 17:52:07.722+03
c40356fe-370b-4a46-a7f5-0e1a58eb0bba	f47b953f-49ae-4c84-a8d7-38acc109cc8d	fc33643ba765a79db8bae11322d1703f5093ffe7d4defef8c4744af4125fc33a	2026-09-15 18:13:05.604+03	2026-09-08 18:13:48.981+03	2026-09-08 18:13:05.605+03
3da46c70-63bc-45c9-b31a-c2af11b76fc5	f47b953f-49ae-4c84-a8d7-38acc109cc8d	0ba428b2bfb199492a43b23e1f7046ce53d897de527b89603b04d49f7659b742	2026-09-08 17:52:20.201+03	2026-09-08 18:14:16.325+03	2026-09-01 17:52:20.201+03
f2e1e7d7-d140-4c69-9989-1da7054e3249	f47b953f-49ae-4c84-a8d7-38acc109cc8d	fc84d89bdf5bcebe320f3b5c9e351122a30bff9f20c5cb94b51ffe516b34b074	2026-09-08 17:52:33.161+03	2026-09-08 18:14:16.325+03	2026-09-01 17:52:33.161+03
1b7e4331-81ad-4ef8-b4be-397fab8980ef	f47b953f-49ae-4c84-a8d7-38acc109cc8d	54771a9159a2a56441a8e93c02666d3cce20b5a76b3ffad6ee4e05a068afedcf	2026-09-15 05:54:03.674+03	2026-09-08 18:14:16.325+03	2026-09-08 05:54:03.68+03
2a3c7fa6-f074-4838-84c3-014fb8b4ffb2	f47b953f-49ae-4c84-a8d7-38acc109cc8d	1b3cf51a2c359f03c2bba16488058cc4ddbc88ea87b839378000d243e9b1a315	2026-09-15 06:02:21.007+03	2026-09-08 18:14:16.325+03	2026-09-08 06:02:21.015+03
0e93606e-479e-4cd0-9b77-8f5a90cf381b	f47b953f-49ae-4c84-a8d7-38acc109cc8d	a0d0a5fc40e16a2d70f1dbbd6bacda71bd3cc6ad52073d28ac5d52e923a8ace9	2026-09-15 07:24:28.988+03	2026-09-08 18:14:16.325+03	2026-09-08 07:24:28.995+03
1522760e-35f1-441b-8ba2-1bc6ed32f5d0	f47b953f-49ae-4c84-a8d7-38acc109cc8d	192733ea1092ef52e74b3c5c9cc854376ba65b5b901ac9e6f7b8602d6709357c	2026-09-15 07:56:36.718+03	2026-09-08 18:14:16.325+03	2026-09-08 07:56:36.726+03
4415c18a-a3ce-4c29-b3e1-45a45bf3f65a	f47b953f-49ae-4c84-a8d7-38acc109cc8d	da984a63611508fda43b7245992c5c0dbebfc45d993d4ec05cb60e3ef9924813	2026-09-15 08:09:34.04+03	2026-09-08 18:14:16.325+03	2026-09-08 08:09:34.046+03
5d32fa15-7d42-42e6-a9b7-de50a4478e0a	f47b953f-49ae-4c84-a8d7-38acc109cc8d	4bb853edf2302f008ae6ebba9dd881025fe8bb4c6ab06fb75a342abdfea09960	2026-09-15 08:17:17.673+03	2026-09-08 18:14:16.325+03	2026-09-08 08:17:17.679+03
febd53e8-e1ec-4859-ad00-69c2565cca94	f47b953f-49ae-4c84-a8d7-38acc109cc8d	0bdbe661d698e223cd9d62df370e611c78d70ba2d870db01ca1a1d9bda87d790	2026-09-15 08:18:19.2+03	2026-09-08 18:14:16.325+03	2026-09-08 08:18:19.201+03
0e29ae18-68be-47f4-96a7-43253b16ad55	f47b953f-49ae-4c84-a8d7-38acc109cc8d	dd1a6315fc009dd624b708cdd61286253d3986990dbf39ee49572e795f7a3c68	2026-09-15 08:19:29.915+03	2026-09-08 18:14:16.325+03	2026-09-08 08:19:29.916+03
c6b79d43-d05a-4002-b401-28839c68128f	f47b953f-49ae-4c84-a8d7-38acc109cc8d	8115954ce777d8cc7615db2943d71dd2372084a6a1236d7b9bab98d22ec18c58	2026-09-15 08:19:50.629+03	2026-09-08 18:14:16.325+03	2026-09-08 08:19:50.629+03
a944efa7-6b0d-4073-870c-bed2fd39f2f0	f47b953f-49ae-4c84-a8d7-38acc109cc8d	d1b54856a12d3b093ca5670412cedf1201d6573a33a2e1259f768ee01a7529d1	2026-09-15 08:20:23.1+03	2026-09-08 18:14:16.325+03	2026-09-08 08:20:23.1+03
1584c6c9-5952-42cc-90b0-660a905367cc	f47b953f-49ae-4c84-a8d7-38acc109cc8d	139ab837b60b547b7a28001b496f3296bc48e183666d6f7cbb43a3711d3d0989	2026-09-15 08:20:47.534+03	2026-09-08 18:14:16.325+03	2026-09-08 08:20:47.534+03
e6a27b4a-d8dc-4401-85cb-2929501e24ff	f47b953f-49ae-4c84-a8d7-38acc109cc8d	76432a3b4abffebbfe4e883994e8d3bcdab1e033673a58b1982862c576406bae	2026-09-15 08:21:46.836+03	2026-09-08 18:14:16.325+03	2026-09-08 08:21:46.836+03
25517235-61e4-4b29-aed3-d374e7572560	f47b953f-49ae-4c84-a8d7-38acc109cc8d	c73c71de8c19b0808a8386df55721336a198106078a921d428e31ad336499849	2026-09-15 08:21:50.496+03	2026-09-08 18:14:16.325+03	2026-09-08 08:21:50.496+03
47d3b9c6-bb79-429d-af6a-1fd455b77b62	f47b953f-49ae-4c84-a8d7-38acc109cc8d	b64fcb04a09e4d611e2f90049e887475671fa78840f9686a63a66cceb085dced	2026-09-15 08:22:18.391+03	2026-09-08 18:14:16.325+03	2026-09-08 08:22:18.391+03
31a07b35-f7be-42d5-9841-b9f5c91c3921	f47b953f-49ae-4c84-a8d7-38acc109cc8d	2727b6ce673ef82c5055210e1dffb02c569bfefdaef0c6c6330bfcbdad7f1ac8	2026-09-15 08:22:26.173+03	2026-09-08 18:14:16.325+03	2026-09-08 08:22:26.173+03
cc4f2978-b215-4bdc-8606-733cc8b86608	f47b953f-49ae-4c84-a8d7-38acc109cc8d	5c73894b5eefbdeee0c58af9e8a8e175649248c64c0b05341f027096faa716c9	2026-09-15 08:22:54.496+03	2026-09-08 18:14:16.325+03	2026-09-08 08:22:54.496+03
2d46762e-9ed3-4d6a-9bc1-541ad3274b02	f47b953f-49ae-4c84-a8d7-38acc109cc8d	ccdc788fca7be8c5f3ccec819ab9d9d4e9fa07ac8c8e5a59b4ff57207b3b943f	2026-09-15 08:22:56.366+03	2026-09-08 18:14:16.325+03	2026-09-08 08:22:56.366+03
229e11b2-6b98-4cdb-908a-d500d7c15d9c	f47b953f-49ae-4c84-a8d7-38acc109cc8d	97e1ef9b6e4c4c432577620966f22d90c734c1ac90a87f1e42aa7e4b3c66d755	2026-09-15 08:29:33.087+03	2026-09-08 18:14:16.325+03	2026-09-08 08:29:33.093+03
02d0b04c-947f-4457-975d-e4da57f14d45	f47b953f-49ae-4c84-a8d7-38acc109cc8d	6dfb9d0858a054fd36de88d50a8bd68cf2e22dd0ad825ac06d24a85c0a7bf7d0	2026-09-15 08:29:42.311+03	2026-09-08 18:14:16.325+03	2026-09-08 08:29:42.312+03
fb6845f6-a6be-431d-8503-8aa29b4895f7	f47b953f-49ae-4c84-a8d7-38acc109cc8d	3e313e9afd68ce219db5ceae7de2a8615782a69c60e0c5740c9e8a73924eed37	2026-09-15 08:29:59.312+03	2026-09-08 18:14:16.325+03	2026-09-08 08:29:59.313+03
8d26d177-d011-47ce-9cbe-9c31136bcfdf	f47b953f-49ae-4c84-a8d7-38acc109cc8d	1e0037f24cf4fb3006c38ef510acf5c7487d8d5619b7e8229c89e6197f68a703	2026-09-15 08:30:13.676+03	2026-09-08 18:14:16.325+03	2026-09-08 08:30:13.676+03
98187415-7573-449e-8e74-afc609a96084	f47b953f-49ae-4c84-a8d7-38acc109cc8d	d77797993c43c901c17c68d6bc81c553e36cb61bdc957976510dbd48951fee90	2026-09-15 08:32:56.691+03	2026-09-08 18:14:16.325+03	2026-09-08 08:32:56.697+03
2ec83279-b840-40eb-a4cb-55b8aa1243db	f47b953f-49ae-4c84-a8d7-38acc109cc8d	d6c09147ee7e72b9b7260eda8514c86e3283c3c4242a8bd53ed18355f53df084	2026-09-15 08:33:11.732+03	2026-09-08 18:14:16.325+03	2026-09-08 08:33:11.732+03
81695ab3-b6ac-42b5-99cf-21006fd2fb03	f47b953f-49ae-4c84-a8d7-38acc109cc8d	293f9ce8495f593dd7b569dee7600944ffd8d9b742e0809ea5371d1ba36d593b	2026-09-15 08:33:32.177+03	2026-09-08 18:14:16.325+03	2026-09-08 08:33:32.177+03
57ca7df6-59b6-4223-a3ba-97d69cf8f90e	f47b953f-49ae-4c84-a8d7-38acc109cc8d	32ab7bda2040550a64d643d2191b51840c7b7343ee1e041eb625b892b3832b9b	2026-09-15 08:35:38.664+03	2026-09-08 18:14:16.325+03	2026-09-08 08:35:38.664+03
a5f7b154-5ca9-4d71-8038-fd38fb8053c7	f47b953f-49ae-4c84-a8d7-38acc109cc8d	0413b56900083566ffcad85e8dcb38dfa4f8e27c51180d93406a3d4f3c386ab7	2026-09-15 08:37:10.904+03	2026-09-08 18:14:16.325+03	2026-09-08 08:37:10.911+03
620fcdd1-3392-4ffd-b251-cd2be5a1d020	f47b953f-49ae-4c84-a8d7-38acc109cc8d	9892aae1f83b4786cfec648be5adc7a66f697003492dfa3a355688540eb5ae7c	2026-09-15 08:37:57.53+03	2026-09-08 18:14:16.325+03	2026-09-08 08:37:57.53+03
f1a99810-11c2-40d4-bbb7-7aeb24ce62a9	f47b953f-49ae-4c84-a8d7-38acc109cc8d	c86554b93ce460fd8baf481965da939f0a72d947bd1cf75a4c24a147d1209f40	2026-09-15 08:40:35.712+03	2026-09-08 18:14:16.325+03	2026-09-08 08:40:35.712+03
4f6a367d-425c-4393-ae8a-d08eeb70a084	f47b953f-49ae-4c84-a8d7-38acc109cc8d	90248ae4d8312ef63974646810b42193420684446641ffca32ff984ef2e70fd1	2026-09-15 09:19:54.372+03	2026-09-08 18:14:16.325+03	2026-09-08 09:19:54.379+03
324acf79-5a07-46ad-a013-fa3364772327	f47b953f-49ae-4c84-a8d7-38acc109cc8d	15d7213a6a09dff37e00301334aa3a2374a42d83a07ed1f01e973c7ab5775de5	2026-09-15 09:24:12.877+03	2026-09-08 18:14:16.325+03	2026-09-08 09:24:12.878+03
5ffd8c2e-1ab4-4d13-bd46-c2ee5fc5391b	f47b953f-49ae-4c84-a8d7-38acc109cc8d	637701b5520c98ef48dec68930f617ab9dfa3b22e63deaf0e94e3552c9f710dd	2026-09-15 09:42:29.267+03	2026-09-08 18:14:16.325+03	2026-09-08 09:42:29.267+03
8d49a50d-a528-45cd-a93d-5298db9237d1	f47b953f-49ae-4c84-a8d7-38acc109cc8d	226b939e882874394b8cd0eb270a1fea1604d4af7a4027b0f70683bf256c066b	2026-09-15 09:49:41.699+03	2026-09-08 18:14:16.325+03	2026-09-08 09:49:41.706+03
4707c193-6885-4440-bed9-476843f48644	f47b953f-49ae-4c84-a8d7-38acc109cc8d	e1df8510c0833fcc03c3fe29ebdda54d863f59056e3a91440657d3d31304b8d9	2026-09-15 09:56:26.592+03	2026-09-08 18:14:16.325+03	2026-09-08 09:56:26.6+03
7db6540f-cb29-483e-8177-03d3143b233b	f47b953f-49ae-4c84-a8d7-38acc109cc8d	7718346c3adc89cd5724fa61f53e0972861791c8772edf5e8d2b8e2e5d473c82	2026-09-15 09:59:44.054+03	2026-09-08 18:14:16.325+03	2026-09-08 09:59:44.061+03
8f4b5728-e8d9-400d-9cc7-416ec5e19ced	f47b953f-49ae-4c84-a8d7-38acc109cc8d	98dc43b6958637c1b5fb78eef913fd3eb2c35feaf7af4eface913be062d58ef2	2026-09-15 10:07:45.992+03	2026-09-08 18:14:16.325+03	2026-09-08 10:07:45.993+03
2036dc52-32db-4ec4-8cf3-2889abdccb75	f47b953f-49ae-4c84-a8d7-38acc109cc8d	58a966c737286756db1c090763bf5af34c901e12806ffdf9c866eefdf543ff71	2026-09-15 13:47:03.978+03	2026-09-08 18:14:16.325+03	2026-09-08 13:47:03.985+03
16af688d-adb7-49b0-a76c-77c9f9b4ef4a	f47b953f-49ae-4c84-a8d7-38acc109cc8d	7fdf83fb7d35935bcb402f42150b3a4f90653bda560142704c16ee4c10d886f8	2026-09-15 18:12:01.653+03	2026-09-08 18:14:16.325+03	2026-09-08 18:12:01.66+03
12f67104-2908-4653-b6c0-ae70ee485467	f47b953f-49ae-4c84-a8d7-38acc109cc8d	d4158eb2a2f6f47c410121f74d641b350ef79878a7e450bb6009d524c55433d9	2026-10-06 11:06:12.227+03	\N	2026-09-29 11:06:12.234+03
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.region (id, country_id, name, created_at, updated_at) FROM stdin;
3076cf18-3d40-4089-97ab-e1bc7ec20585	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ANALAMANGA	2026-08-26 19:16:48.783159+03	\N
53abeaf5-879d-48b8-88f7-d8744ae7da23	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	BONGOLAVA	2026-08-26 19:16:48.783159+03	\N
fa449858-0e93-40dc-82bf-6010a1b095c1	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ITASY	2026-08-26 19:16:48.783159+03	\N
600a3f29-9ad3-4e86-bdb8-d9e6971626a3	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	VAKINANKARATRA	2026-08-26 19:16:48.783159+03	\N
dab45306-3057-49b9-97d9-d988b03a95ef	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	DIANA	2026-08-26 19:16:48.783159+03	\N
04566928-9320-43c9-b232-54ed425a6dd5	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	SAVA	2026-08-26 19:16:48.783159+03	\N
af33442f-81de-4b16-be94-6828e7ccea13	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	AMORON'I MANIA	2026-08-26 19:16:48.783159+03	\N
570e1b05-c66a-42c9-a348-d49f82380c5e	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	HAUTE MATSIATRA	2026-08-26 19:16:48.783159+03	\N
ecf38f6c-6b69-447c-9b36-14ebd3c933a8	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	VATOVAVY	2026-08-26 19:16:48.783159+03	\N
c2c230e9-18a0-4659-ba08-587c3007884e	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	FITOVINANY	2026-08-26 19:16:48.783159+03	\N
f4424d78-7e70-48ee-a7be-fda78ec7cb24	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ATSIMO-ATSINANANA	2026-08-26 19:16:48.783159+03	\N
9a8888a3-f7de-4e00-975c-25a241576be8	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	IHOROMBE	2026-08-26 19:16:48.783159+03	\N
f0503161-cff5-42ca-80d1-a9516d638679	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	MENABE	2026-08-26 19:16:48.783159+03	\N
25f9f103-2f56-4a78-9020-8559627f5595	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ATSIMO-ANDREFANA	2026-08-26 19:16:48.783159+03	\N
8c2c8276-1c02-410e-86cf-37352849d8fb	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ANDROY	2026-08-26 19:16:48.783159+03	\N
94c84bdd-d4ed-438c-b7c7-ac355c4fd011	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ANOSY	2026-08-26 19:16:48.783159+03	\N
7632eda7-b735-4b39-809c-c86b38aaad55	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	BOENY	2026-08-26 19:16:48.783159+03	\N
1888bb0b-ce79-493f-b02b-082b250086db	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	SOFIA	2026-08-26 19:16:48.783159+03	\N
6c669eef-66d2-4579-9b90-f2598695ad45	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	BETSIBOKA	2026-08-26 19:16:48.783159+03	\N
179d9791-0b5c-41e6-a054-1e193d9a8807	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	MELAKY	2026-08-26 19:16:48.783159+03	\N
0a03339e-6539-47ff-a067-aaab3938b504	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ALAOTRA-MANGORO	2026-08-26 19:16:48.783159+03	\N
48d5d30c-4b1a-431c-96a5-f4e058ac6a0a	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ATSINANANA	2026-08-26 19:16:48.783159+03	\N
19dde41a-0c2a-4663-89dc-ac453c63d8cb	9d4a3e6b-4971-4baa-94ea-aa42489a2c54	ANALANJIROFO	2026-08-26 19:16:48.783159+03	\N
\.


--
-- Name: agent agent_username_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT agent_username_key UNIQUE (username);


--
-- Name: password_reset_otp password_reset_otp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_otp
    ADD CONSTRAINT password_reset_otp_pkey PRIMARY KEY (id);


--
-- Name: password_reset_token password_reset_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT password_reset_token_pkey PRIMARY KEY (id);


--
-- Name: password_reset_token password_reset_token_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT password_reset_token_token_hash_key UNIQUE (token_hash);


--
-- Name: address pk_address; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT pk_address PRIMARY KEY (id);


--
-- Name: application_role pk_application_role; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_role
    ADD CONSTRAINT pk_application_role PRIMARY KEY (id);


--
-- Name: centre pk_centre; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.centre
    ADD CONSTRAINT pk_centre PRIMARY KEY (id);


--
-- Name: citizen pk_citizen; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.citizen
    ADD CONSTRAINT pk_citizen PRIMARY KEY (id);


--
-- Name: citizen_account pk_citizen_account; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.citizen_account
    ADD CONSTRAINT pk_citizen_account PRIMARY KEY (id);


--
-- Name: commune pk_commune; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.commune
    ADD CONSTRAINT pk_commune PRIMARY KEY (id);


--
-- Name: contact_method pk_contact_method; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contact_method
    ADD CONSTRAINT pk_contact_method PRIMARY KEY (id);


--
-- Name: district pk_district; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT pk_district PRIMARY KEY (id);


--
-- Name: document pk_document; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT pk_document PRIMARY KEY (id);


--
-- Name: document_mrz pk_document_mrz; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_mrz
    ADD CONSTRAINT pk_document_mrz PRIMARY KEY (id);


--
-- Name: document_ocr_result pk_document_ocr_result; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_ocr_result
    ADD CONSTRAINT pk_document_ocr_result PRIMARY KEY (id);


--
-- Name: document_type pk_document_type; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_type
    ADD CONSTRAINT pk_document_type PRIMARY KEY (id);


--
-- Name: enrolment pk_enrolment; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrolment
    ADD CONSTRAINT pk_enrolment PRIMARY KEY (id);


--
-- Name: face_biometrics pk_face_biometrics; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.face_biometrics
    ADD CONSTRAINT pk_face_biometrics PRIMARY KEY (id);


--
-- Name: family_relationships pk_family_relationships; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.family_relationships
    ADD CONSTRAINT pk_family_relationships PRIMARY KEY (id);


--
-- Name: fokontany pk_fokontany; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.fokontany
    ADD CONSTRAINT pk_fokontany PRIMARY KEY (id);


--
-- Name: person pk_person; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT pk_person PRIMARY KEY (id);


--
-- Name: country pk_tbl; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT pk_tbl PRIMARY KEY (id);


--
-- Name: region pk_tbl_0; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT pk_tbl_0 PRIMARY KEY (id);


--
-- Name: agent pk_tbl_1; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT pk_tbl_1 PRIMARY KEY (id);


--
-- Name: refresh_token refresh_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_pkey PRIMARY KEY (id);


--
-- Name: refresh_token refresh_token_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT refresh_token_token_hash_key UNIQUE (token_hash);


--
-- Name: idx_password_reset_otp_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_password_reset_otp_agent_id ON public.password_reset_otp USING btree (agent_id);


--
-- Name: idx_password_reset_token_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_password_reset_token_agent_id ON public.password_reset_token USING btree (agent_id);


--
-- Name: idx_refresh_token_agent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_token_agent_id ON public.refresh_token USING btree (agent_id);


--
-- Name: uq_refresh_token_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_refresh_token_token_hash ON public.refresh_token USING btree (token_hash);


--
-- Name: address fk_address_fokontany; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT fk_address_fokontany FOREIGN KEY (id_fokontany) REFERENCES public.fokontany(id);


--
-- Name: address fk_address_person; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT fk_address_person FOREIGN KEY (id_person) REFERENCES public.person(id);


--
-- Name: centre fk_centre_fokontany; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.centre
    ADD CONSTRAINT fk_centre_fokontany FOREIGN KEY (id_fokontany) REFERENCES public.fokontany(id);


--
-- Name: citizen_account fk_citizen_account_citizen; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.citizen_account
    ADD CONSTRAINT fk_citizen_account_citizen FOREIGN KEY (id_citizen) REFERENCES public.citizen(id);


--
-- Name: citizen fk_citizen_person; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.citizen
    ADD CONSTRAINT fk_citizen_person FOREIGN KEY (person_id) REFERENCES public.person(id);


--
-- Name: commune fk_commune_district; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.commune
    ADD CONSTRAINT fk_commune_district FOREIGN KEY (district_id) REFERENCES public.district(id);


--
-- Name: contact_method fk_contact_method_person; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contact_method
    ADD CONSTRAINT fk_contact_method_person FOREIGN KEY (person_id) REFERENCES public.person(id);


--
-- Name: district fk_district_region; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.district
    ADD CONSTRAINT fk_district_region FOREIGN KEY (region_id) REFERENCES public.region(id);


--
-- Name: document fk_document_document_type; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT fk_document_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id);


--
-- Name: document fk_document_enrolment; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT fk_document_enrolment FOREIGN KEY (enrolment_id) REFERENCES public.enrolment(id);


--
-- Name: document_mrz fk_document_mrz_document; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_mrz
    ADD CONSTRAINT fk_document_mrz_document FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- Name: document_ocr_result fk_document_ocr_result_document; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.document_ocr_result
    ADD CONSTRAINT fk_document_ocr_result_document FOREIGN KEY (document_id) REFERENCES public.document(id);


--
-- Name: enrolment fk_enrolment_agent; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrolment
    ADD CONSTRAINT fk_enrolment_agent FOREIGN KEY (agent_id) REFERENCES public.agent(id);


--
-- Name: enrolment fk_enrolment_citizen; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrolment
    ADD CONSTRAINT fk_enrolment_citizen FOREIGN KEY (citizen_id) REFERENCES public.citizen(id);


--
-- Name: face_biometrics fk_face_biometrics_enrolment; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.face_biometrics
    ADD CONSTRAINT fk_face_biometrics_enrolment FOREIGN KEY (enrolment_id) REFERENCES public.enrolment(id);


--
-- Name: family_relationships fk_family_relationships_citizen; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.family_relationships
    ADD CONSTRAINT fk_family_relationships_citizen FOREIGN KEY (citizen_id) REFERENCES public.citizen(id);


--
-- Name: family_relationships fk_family_relationships_citizen_0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.family_relationships
    ADD CONSTRAINT fk_family_relationships_citizen_0 FOREIGN KEY (related_person_id) REFERENCES public.citizen(id);


--
-- Name: fokontany fk_fokontany_commune; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.fokontany
    ADD CONSTRAINT fk_fokontany_commune FOREIGN KEY (commune_id) REFERENCES public.commune(id);


--
-- Name: password_reset_otp fk_password_reset_otp_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_otp
    ADD CONSTRAINT fk_password_reset_otp_agent FOREIGN KEY (agent_id) REFERENCES public.agent(id);


--
-- Name: password_reset_token fk_password_reset_token_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_token
    ADD CONSTRAINT fk_password_reset_token_agent FOREIGN KEY (agent_id) REFERENCES public.agent(id);


--
-- Name: person fk_person_country; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT fk_person_country FOREIGN KEY (id_country_of_birth) REFERENCES public.country(id);


--
-- Name: refresh_token fk_refresh_token_agent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token
    ADD CONSTRAINT fk_refresh_token_agent FOREIGN KEY (agent_id) REFERENCES public.agent(id);


--
-- Name: region fk_region_country; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT fk_region_country FOREIGN KEY (country_id) REFERENCES public.country(id);


--
-- Name: agent fk_user_application_role; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT fk_user_application_role FOREIGN KEY (id_application_role) REFERENCES public.application_role(id);


--
-- Name: agent fk_user_centre; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT fk_user_centre FOREIGN KEY (id_centre) REFERENCES public.centre(id);


--
-- Name: agent fk_user_person; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.agent
    ADD CONSTRAINT fk_user_person FOREIGN KEY (person_id) REFERENCES public.person(id);


--
-- PostgreSQL database dump complete
--

\unrestrict TajHqodeqT7ob1cOz1oGbe26ldPVCSvXmgdxnQ97DG4wSCWcyYtCotoKBI9kAxp

