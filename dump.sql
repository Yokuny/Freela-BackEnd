--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calcular_distancia(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: yokuny
--

CREATE FUNCTION public.calcular_distancia(partida_latitude numeric, partida_longitude numeric, destino_latitude numeric, destino_longitude numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    raio_terra CONSTANT NUMERIC := 6371; -- raio médio da Terra em quilômetros
    dlat NUMERIC := RADIANS(destino_latitude - partida_latitude);
    dlon NUMERIC := RADIANS(destino_longitude - partida_longitude);
    a NUMERIC := SIN(dlat/2) * SIN(dlat/2) +
                  COS(RADIANS(partida_latitude)) * COS(RADIANS(destino_latitude)) *
                  SIN(dlon/2) * SIN(dlon/2);
    c NUMERIC := 2 * ATAN2(SQRT(a), SQRT(1-a));
    distancia NUMERIC := raio_terra * c;
BEGIN
    RETURN distancia;
END;
$$;


ALTER FUNCTION public.calcular_distancia(partida_latitude numeric, partida_longitude numeric, destino_latitude numeric, destino_longitude numeric) OWNER TO yokuny;

--
-- Name: calcular_hora_chegada_trigger(); Type: FUNCTION; Schema: public; Owner: yokuny
--

CREATE FUNCTION public.calcular_hora_chegada_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    tempo_km NUMERIC := 0.2; -- tempo em horas para percorrer 1 quilômetro (assumindo uma velocidade média de 300 km/h)
    distancia NUMERIC;
    tempo_viagem INTERVAL;
BEGIN
    -- Calcular a distância entre as cidades de partida e destino
    distancia := calcular_distancia(
        (SELECT latitude FROM cidades WHERE id = NEW.cidade_partida_id),
        (SELECT longitude FROM cidades WHERE id = NEW.cidade_partida_id),
        (SELECT latitude FROM cidades WHERE id = NEW.cidade_destino_id),
        (SELECT longitude FROM cidades WHERE id = NEW.cidade_destino_id)
    );

    -- Calcular o tempo de viagem com base na distância
    tempo_viagem := distancia * tempo_km * INTERVAL '1 hour';

    -- Calcular a hora de chegada com base na hora de partida e no tempo de viagem
    NEW.hora_chegada := NEW.hora_partida + tempo_viagem;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calcular_hora_chegada_trigger() OWNER TO yokuny;

--
-- Name: calcular_preco_trigger(); Type: FUNCTION; Schema: public; Owner: yokuny
--

CREATE FUNCTION public.calcular_preco_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    taxa_km NUMERIC := 0.50; -- taxa por quilômetro percorrido
    distancia NUMERIC;
BEGIN
    -- Calcular a distância entre as cidades de partida e destino
    distancia := calcular_distancia(
        (SELECT latitude FROM cidades WHERE id = NEW.cidade_partida_id),
        (SELECT longitude FROM cidades WHERE id = NEW.cidade_partida_id),
        (SELECT latitude FROM cidades WHERE id = NEW.cidade_destino_id),
        (SELECT longitude FROM cidades WHERE id = NEW.cidade_destino_id)
    );

    -- Calcular o preço com base na distância
    NEW.preco := distancia * taxa_km;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calcular_preco_trigger() OWNER TO yokuny;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cidades; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.cidades (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    latitude numeric(10,6) NOT NULL,
    longitude numeric(10,6) NOT NULL
);


ALTER TABLE public.cidades OWNER TO yokuny;

--
-- Name: cidades_id_seq; Type: SEQUENCE; Schema: public; Owner: yokuny
--

CREATE SEQUENCE public.cidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cidades_id_seq OWNER TO yokuny;

--
-- Name: cidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yokuny
--

ALTER SEQUENCE public.cidades_id_seq OWNED BY public.cidades.id;


--
-- Name: comodidades; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.comodidades (
    id integer NOT NULL,
    nome character varying(100) NOT NULL
);


ALTER TABLE public.comodidades OWNER TO yokuny;

--
-- Name: comodidades_id_seq; Type: SEQUENCE; Schema: public; Owner: yokuny
--

CREATE SEQUENCE public.comodidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comodidades_id_seq OWNER TO yokuny;

--
-- Name: comodidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yokuny
--

ALTER SEQUENCE public.comodidades_id_seq OWNED BY public.comodidades.id;


--
-- Name: companhias_aereas; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.companhias_aereas (
    id integer NOT NULL,
    nome character varying(100) NOT NULL
);


ALTER TABLE public.companhias_aereas OWNER TO yokuny;

--
-- Name: companhias_aereas_id_seq; Type: SEQUENCE; Schema: public; Owner: yokuny
--

CREATE SEQUENCE public.companhias_aereas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companhias_aereas_id_seq OWNER TO yokuny;

--
-- Name: companhias_aereas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yokuny
--

ALTER SEQUENCE public.companhias_aereas_id_seq OWNED BY public.companhias_aereas.id;


--
-- Name: hoteis; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.hoteis (
    id integer NOT NULL,
    cidade_id integer,
    nome character varying(100) NOT NULL,
    descricao text,
    preco_diaria numeric(10,2)
);


ALTER TABLE public.hoteis OWNER TO yokuny;

--
-- Name: hoteis_id_seq; Type: SEQUENCE; Schema: public; Owner: yokuny
--

CREATE SEQUENCE public.hoteis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hoteis_id_seq OWNER TO yokuny;

--
-- Name: hoteis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yokuny
--

ALTER SEQUENCE public.hoteis_id_seq OWNED BY public.hoteis.id;


--
-- Name: hotel_comodidades; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.hotel_comodidades (
    hotel_id integer NOT NULL,
    comodidade_id integer NOT NULL
);


ALTER TABLE public.hotel_comodidades OWNER TO yokuny;

--
-- Name: voos; Type: TABLE; Schema: public; Owner: yokuny
--

CREATE TABLE public.voos (
    id integer NOT NULL,
    cidade_partida_id integer,
    cidade_destino_id integer,
    companhia_aerea_id integer,
    hora_partida timestamp without time zone,
    hora_chegada timestamp without time zone,
    preco numeric(10,2)
);


ALTER TABLE public.voos OWNER TO yokuny;

--
-- Name: voos_id_seq; Type: SEQUENCE; Schema: public; Owner: yokuny
--

CREATE SEQUENCE public.voos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voos_id_seq OWNER TO yokuny;

--
-- Name: voos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: yokuny
--

ALTER SEQUENCE public.voos_id_seq OWNED BY public.voos.id;


--
-- Name: cidades id; Type: DEFAULT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.cidades ALTER COLUMN id SET DEFAULT nextval('public.cidades_id_seq'::regclass);


--
-- Name: comodidades id; Type: DEFAULT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.comodidades ALTER COLUMN id SET DEFAULT nextval('public.comodidades_id_seq'::regclass);


--
-- Name: companhias_aereas id; Type: DEFAULT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.companhias_aereas ALTER COLUMN id SET DEFAULT nextval('public.companhias_aereas_id_seq'::regclass);


--
-- Name: hoteis id; Type: DEFAULT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hoteis ALTER COLUMN id SET DEFAULT nextval('public.hoteis_id_seq'::regclass);


--
-- Name: voos id; Type: DEFAULT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos ALTER COLUMN id SET DEFAULT nextval('public.voos_id_seq'::regclass);


--
-- Data for Name: cidades; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.cidades (id, nome, latitude, longitude) FROM stdin;
1	São Paulo	-23.550520	-46.633308
2	Rio de Janeiro	-22.906847	-43.172897
3	Salvador	-12.971598	-38.501675
4	Brasília	-15.794228	-47.882166
5	Fortaleza	-3.731861	-38.526670
6	Belo Horizonte	-19.916681	-43.934493
7	Curitiba	-25.428356	-49.273252
8	Manaus	-3.119028	-60.021731
9	Recife	-8.054277	-34.881256
10	Porto Alegre	-30.033060	-51.230465
11	Vitória	-20.320087	-40.338683
12	Goiânia	-16.686898	-49.264794
13	Natal	-5.779257	-35.200916
14	Belém	-1.455754	-48.490180
15	Florianópolis	-27.594870	-48.548219
16	João Pessoa	-7.119495	-34.845011
17	Maceió	-9.649848	-35.708949
18	Campo Grande	-20.464213	-54.616147
19	Cuiabá	-15.598917	-56.094894
20	Porto Velho	-8.761160	-63.900430
21	São Luís	-2.532540	-44.305590
22	Teresina	-5.092010	-42.803760
23	Aracaju	-10.947247	-37.073082
24	Foz do Iguaçu	-25.516073	-54.585399
25	Maringá	-23.427299	-51.937659
26	Uberlândia	-18.918299	-48.277144
27	Ribeirão Preto	-21.170402	-47.810323
28	Campinas	-22.907104	-47.063240
29	Joinville	-26.305347	-48.846168
\.


--
-- Data for Name: comodidades; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.comodidades (id, nome) FROM stdin;
1	Wi-Fi
2	Estacionamento
3	Academia
4	Piscina
5	Restaurante
6	Serviço de Quarto
7	Ar Condicionado
8	Café da Manhã
9	Spa
10	Bar
\.


--
-- Data for Name: companhias_aereas; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.companhias_aereas (id, nome) FROM stdin;
1	LATAM Airlines
2	Gol Linhas Aéreas
3	Azul Linhas Aéreas
4	Avianca Brasil
5	TAP Air Portugal
6	American Airlines
7	United Airlines
8	Air France
9	British Airways
10	Lufthansa
11	Emirates
12	Qatar Airways
13	Copa Airlines
14	Turkish Airlines
15	Delta Air Lines
16	Air Canada
17	Iberia
18	KLM Royal Dutch Airlines
19	Air Europa
20	Alitalia
\.


--
-- Data for Name: hoteis; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.hoteis (id, cidade_id, nome, descricao, preco_diaria) FROM stdin;
90	1	Hotel 2	Descrição do hotel 2	298.98
91	1	Hotel 1	Descrição do hotel 1	106.52
92	2	Hotel 1	Descrição do hotel 1	117.63
93	2	Hotel 2	Descrição do hotel 2	291.73
94	3	Hotel 1	Descrição do hotel 1	207.91
95	3	Hotel 2	Descrição do hotel 2	314.51
96	4	Hotel 1	Descrição do hotel 1	231.19
97	4	Hotel 2	Descrição do hotel 2	331.24
98	5	Hotel 1	Descrição do hotel 1	156.46
99	5	Hotel 2	Descrição do hotel 2	341.05
100	6	Hotel 2	Descrição do hotel 2	377.24
101	6	Hotel 1	Descrição do hotel 1	78.18
102	7	Hotel 1	Descrição do hotel 1	183.14
103	7	Hotel 2	Descrição do hotel 2	184.57
104	8	Hotel 2	Descrição do hotel 2	358.40
105	8	Hotel 1	Descrição do hotel 1	109.14
106	9	Hotel 1	Descrição do hotel 1	78.05
107	9	Hotel 2	Descrição do hotel 2	123.72
108	10	Hotel 1	Descrição do hotel 1	180.18
109	10	Hotel 2	Descrição do hotel 2	334.74
110	11	Hotel 1	Descrição do hotel 1	265.71
111	11	Hotel 2	Descrição do hotel 2	267.97
112	12	Hotel 1	Descrição do hotel 1	372.23
113	12	Hotel 2	Descrição do hotel 2	393.35
114	13	Hotel 2	Descrição do hotel 2	222.39
115	13	Hotel 1	Descrição do hotel 1	218.95
116	14	Hotel 1	Descrição do hotel 1	186.28
117	14	Hotel 2	Descrição do hotel 2	204.68
118	15	Hotel 2	Descrição do hotel 2	357.62
119	15	Hotel 1	Descrição do hotel 1	280.01
120	16	Hotel 2	Descrição do hotel 2	348.29
121	16	Hotel 1	Descrição do hotel 1	150.06
122	17	Hotel 1	Descrição do hotel 1	157.94
123	17	Hotel 2	Descrição do hotel 2	169.85
124	18	Hotel 2	Descrição do hotel 2	289.29
125	18	Hotel 1	Descrição do hotel 1	76.04
126	19	Hotel 1	Descrição do hotel 1	206.23
127	19	Hotel 2	Descrição do hotel 2	325.93
128	20	Hotel 2	Descrição do hotel 2	312.67
129	20	Hotel 1	Descrição do hotel 1	187.09
130	21	Hotel 2	Descrição do hotel 2	371.45
131	21	Hotel 1	Descrição do hotel 1	174.32
132	22	Hotel 2	Descrição do hotel 2	208.60
133	22	Hotel 1	Descrição do hotel 1	107.48
134	23	Hotel 2	Descrição do hotel 2	310.02
135	23	Hotel 1	Descrição do hotel 1	102.02
136	24	Hotel 2	Descrição do hotel 2	258.94
137	24	Hotel 1	Descrição do hotel 1	246.04
138	25	Hotel 2	Descrição do hotel 2	380.56
139	25	Hotel 1	Descrição do hotel 1	289.05
140	26	Hotel 1	Descrição do hotel 1	138.00
141	26	Hotel 2	Descrição do hotel 2	378.45
142	27	Hotel 1	Descrição do hotel 1	236.49
143	27	Hotel 2	Descrição do hotel 2	392.48
144	28	Hotel 2	Descrição do hotel 2	207.52
145	28	Hotel 1	Descrição do hotel 1	168.46
146	29	Hotel 2	Descrição do hotel 2	339.58
147	29	Hotel 1	Descrição do hotel 1	307.50
\.


--
-- Data for Name: hotel_comodidades; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.hotel_comodidades (hotel_id, comodidade_id) FROM stdin;
\.


--
-- Data for Name: voos; Type: TABLE DATA; Schema: public; Owner: yokuny
--

COPY public.voos (id, cidade_partida_id, cidade_destino_id, companhia_aerea_id, hora_partida, hora_chegada, preco) FROM stdin;
1	21	14	15	2023-05-26 16:41:07.712616	2023-05-30 16:43:19.88746	240.09
2	21	5	10	2023-05-26 17:27:13.415009	2023-06-01 04:31:08.59088	327.66
3	23	11	15	2023-05-26 17:29:40.907885	2023-06-04 21:19:33.969712	549.58
4	10	26	19	2023-05-26 17:32:34.507433	2023-06-06 07:48:47.517533	635.68
5	26	25	3	2023-05-26 17:57:53.609957	2023-05-31 23:42:53.862985	314.38
6	1	4	16	2023-05-26 18:25:17.244575	2023-06-03 00:52:50.290684	436.15
7	20	11	17	2023-05-26 19:44:01.62248	2023-06-19 11:13:46.258581	1418.74
8	29	6	13	2023-05-26 20:32:41.429015	2023-06-03 02:30:16.360753	434.90
9	10	25	1	2023-05-26 20:33:49.126962	2023-06-02 00:08:15.993077	368.94
10	5	16	5	2023-05-26 20:40:59.327804	2023-05-31 11:40:03.217448	277.46
11	21	18	4	2023-05-26 21:19:59.083968	2023-06-14 22:32:49.953598	1143.04
12	27	17	9	2023-05-26 21:59:20.217571	2023-06-11 02:12:36.717488	910.55
13	12	15	7	2023-05-26 22:02:09.914657	2023-06-06 01:03:53.849579	607.57
14	7	21	16	2023-05-26 22:23:51.651494	2023-06-17 14:33:53.558287	1300.42
15	19	26	9	2023-05-26 22:54:58.192726	2023-06-03 12:34:49.373225	454.16
16	27	18	19	2023-05-27 00:38:26.119162	2023-06-01 22:58:18.586086	355.83
17	19	4	9	2023-05-27 00:42:32.687196	2023-06-03 08:34:59.490284	439.69
18	7	9	5	2023-05-27 00:47:34.661944	2023-06-16 13:00:13.253605	1230.53
19	10	13	15	2023-05-27 01:44:48.523065	2023-06-22 13:04:57.361181	1588.34
20	15	23	20	2023-05-27 03:24:23.330137	2023-06-14 12:26:50.939494	1102.60
21	10	9	13	2023-05-27 03:25:06.365631	2023-06-20 23:12:40.741031	1489.48
22	10	27	9	2023-05-27 03:51:04.985757	2023-06-04 20:30:14.224171	521.63
23	12	10	19	2023-05-27 05:37:58.900769	2023-06-08 17:07:11.623749	748.72
24	12	8	12	2023-05-27 07:07:35.834892	2023-06-12 05:36:23.882643	956.20
25	5	14	9	2023-05-27 07:08:23.762168	2023-06-05 18:11:25.232743	567.63
26	13	26	18	2023-05-27 07:11:57.037915	2023-06-13 06:12:31.206759	1017.52
27	2	10	10	2023-05-27 10:24:56.700686	2023-06-05 19:45:35.189332	563.36
28	18	9	14	2023-05-27 10:31:16.663886	2023-06-17 12:37:38.319574	1265.27
29	8	11	4	2023-05-27 10:32:21.15188	2023-06-20 07:35:48.43053	1432.64
30	25	2	18	2023-05-27 10:36:26.827999	2023-06-03 22:09:15.385234	448.87
31	9	10	20	2023-05-27 10:40:32.176174	2023-06-21 06:28:06.551574	1489.48
32	18	7	14	2023-05-27 10:41:18.532085	2023-06-02 22:04:55.245246	388.48
33	6	9	5	2023-05-27 10:54:14.410054	2023-06-10 02:55:20.605997	820.05
34	14	9	11	2023-05-27 11:07:23.040668	2023-06-10 10:22:36.236289	838.13
35	16	1	20	2023-05-27 11:24:36.043996	2023-06-14 23:07:59.971528	1109.31
36	13	6	13	2023-05-27 11:30:11.438618	2023-06-11 18:14:08.853429	916.83
37	9	11	3	2023-05-27 11:38:56.18503	2023-06-08 20:37:01.120625	742.42
38	12	1	14	2023-05-27 11:54:47.023468	2023-06-03 06:07:37.805593	405.54
39	28	2	10	2023-05-27 12:17:57.756017	2023-05-30 19:59:29.089796	199.23
40	10	29	15	2023-05-27 12:42:54.380069	2023-05-31 11:52:41.228413	237.91
41	17	24	12	2023-05-27 13:38:00.156293	2023-06-18 17:46:31.641501	1330.36
42	3	9	8	2023-05-27 13:56:45.440907	2023-06-02 04:55:55.258406	337.47
43	7	26	19	2023-05-27 14:00:12.600153	2023-06-02 16:13:27.80876	365.55
44	12	25	19	2023-05-27 14:04:42.203093	2023-06-03 06:01:25.881923	399.86
45	8	23	4	2023-05-27 14:23:10.382763	2023-06-18 21:32:38.604863	1337.89
46	5	26	20	2023-05-27 14:48:04.455141	2023-06-13 05:30:30.430055	996.77
47	8	20	1	2023-05-27 15:16:30.75543	2023-06-02 23:15:27.847702	379.96
48	23	1	10	2023-05-27 15:43:18.129774	2023-06-11 01:30:08.727057	864.45
49	23	15	3	2023-05-27 16:01:52.247664	2023-06-15 01:04:19.857021	1102.60
50	21	15	4	2023-05-27 16:14:06.526514	2023-06-20 04:50:59.330035	1411.54
51	14	17	18	2023-05-27 16:15:21.751257	2023-06-10 16:33:36.265298	840.76
52	28	18	17	2023-05-27 17:02:05.005637	2023-06-03 14:16:09.630072	413.09
53	11	16	7	2023-05-27 17:12:50.131325	2023-06-09 21:44:57.437058	791.34
54	6	2	10	2023-05-27 17:14:44.089525	2023-05-30 13:35:13.722673	170.85
55	5	22	8	2023-05-27 17:21:05.210856	2023-05-31 20:53:33.115702	248.85
56	2	5	16	2023-05-27 18:32:42.476577	2023-06-15 00:32:40.352596	1095.00
57	4	24	8	2023-05-27 20:46:20.897143	2023-06-07 13:56:04.723388	642.91
58	7	18	19	2023-05-27 20:55:26.880713	2023-06-03 08:19:03.593874	388.48
59	23	25	20	2023-05-27 21:02:40.579099	2023-06-14 08:49:01.663595	1049.43
60	9	4	6	2023-05-27 21:27:09.245766	2023-06-10 16:21:43.293523	827.27
61	26	25	20	2023-05-27 22:17:09.460692	2023-06-02 04:02:09.71372	314.38
62	19	14	2	2023-05-27 22:37:22.889906	2023-06-11 18:38:29.495865	890.05
63	10	15	18	2023-05-27 22:49:33.262134	2023-05-31 02:07:51.532006	188.26
64	16	27	6	2023-05-27 23:20:52.531372	2023-06-14 10:04:07.454405	1046.80
65	17	21	9	2023-05-27 23:37:01.645331	2023-06-07 06:53:15.562409	618.18
66	20	22	20	2023-05-28 01:02:59.516681	2023-06-16 17:46:04.237674	1181.79
67	14	25	6	2023-05-28 02:19:38.447904	2023-06-17 16:34:28.67213	1235.62
68	21	7	8	2023-05-28 04:03:02.593358	2023-06-18 20:13:04.500151	1300.42
69	21	3	9	2023-05-28 04:29:59.95339	2023-06-08 05:27:38.773724	662.40
70	14	4	6	2023-05-28 04:49:45.06721	2023-06-10 11:58:51.064201	797.88
71	22	15	15	2023-05-28 05:22:34.9114	2023-06-18 16:22:30.631604	1287.50
72	7	5	15	2023-05-28 05:35:44.556813	2023-06-19 11:56:43.089662	1335.87
73	11	28	15	2023-05-28 06:03:53.55628	2023-06-03 12:30:17.61928	376.10
74	27	19	10	2023-05-28 06:25:30.421843	2023-06-06 04:37:40.072341	535.51
75	29	18	19	2023-05-28 09:06:29.985574	2023-06-04 16:23:41.639183	438.22
76	16	18	12	2023-05-28 10:47:44.869221	2023-06-19 01:46:08.384618	1297.43
77	29	13	12	2023-05-28 11:07:55.267699	2023-06-19 23:44:17.503121	1351.52
78	22	16	20	2023-05-28 12:10:19.988164	2023-06-05 01:50:10.005325	454.16
79	26	22	6	2023-05-28 13:54:40.259198	2023-06-11 07:31:13.318565	824.02
80	20	21	2	2023-05-28 14:39:56.217609	2023-06-16 13:40:34.420598	1137.53
81	9	10	6	2023-05-28 14:51:56.271488	2023-06-22 10:39:30.646888	1489.48
82	13	15	8	2023-05-28 15:25:15.658256	2023-06-21 00:37:10.204892	1403.00
83	12	6	7	2023-05-28 16:17:08.404176	2023-06-03 05:46:37.661481	333.73
84	11	10	20	2023-05-28 17:16:12.585797	2023-06-10 12:40:10.951161	768.50
85	11	29	18	2023-05-28 19:04:00.888762	2023-06-06 21:49:31.760577	546.90
86	11	24	11	2023-05-28 19:05:29.689515	2023-06-10 20:42:34.97	784.05
87	11	29	13	2023-05-28 19:20:46.418829	2023-06-06 22:06:17.290644	546.90
88	2	14	14	2023-05-28 19:45:11.827246	2023-06-18 06:25:30.863617	1226.68
89	21	5	20	2023-05-28 21:08:21.169086	2023-06-03 08:12:16.344957	327.66
90	18	24	18	2023-05-28 21:26:35.566466	2023-06-02 13:47:35.574316	280.88
91	5	1	19	2023-05-28 21:29:08.950878	2023-06-17 15:23:34.115946	1184.77
92	28	27	5	2023-05-28 21:47:27.019042	2023-05-30 15:22:12.590481	103.95
93	22	12	9	2023-05-28 22:23:38.866872	2023-06-10 04:12:11.559076	734.52
94	19	17	13	2023-05-28 22:38:26.037005	2023-06-17 04:04:25.612662	1153.58
95	1	10	12	2023-05-28 22:39:05.88698	2023-06-05 01:13:33.120433	426.44
96	28	27	14	2023-05-28 22:49:05.668509	2023-05-30 16:23:51.239948	103.95
97	8	10	1	2023-05-29 00:01:10.838829	2023-06-24 02:32:44.515156	1566.32
98	23	7	17	2023-05-29 00:34:37.936699	2023-06-15 04:28:35.632559	1029.75
99	8	10	20	2023-05-29 00:45:07.945013	2023-06-24 03:16:41.62134	1566.32
100	21	7	1	2023-05-29 03:21:16.45346	2023-06-19 19:31:18.360253	1300.42
101	20	13	10	2023-05-29 05:10:01.810199	2023-06-24 17:33:52.202305	1590.99
102	20	17	6	2023-05-29 05:47:07.675548	2023-06-24 00:48:21.899217	1547.55
103	27	8	1	2023-05-29 08:19:00.36592	2023-06-18 08:54:17.937987	1201.47
104	13	7	11	2023-05-29 08:36:07.611012	2023-06-20 10:22:49.650539	1324.45
105	14	17	3	2023-05-29 09:48:20.446535	2023-06-12 10:06:34.960576	840.76
106	24	28	6	2023-05-29 11:25:43.651245	2023-06-05 06:37:19.158619	407.98
107	28	29	9	2023-05-29 11:28:30.812276	2023-06-01 23:12:10.049632	209.32
108	14	4	12	2023-05-29 11:59:50.601421	2023-06-11 19:08:56.598412	797.88
109	11	3	10	2023-05-29 12:39:17.503318	2023-06-05 12:41:30.496844	420.09
110	2	19	5	2023-05-29 13:44:08.927018	2023-06-11 17:43:13.060954	789.96
111	5	25	8	2023-05-29 13:48:08.514693	2023-06-20 10:06:38.373087	1310.77
112	14	28	17	2023-05-29 13:59:22.112063	2023-06-18 12:02:22.876604	1195.13
113	26	29	16	2023-05-29 14:01:03.528434	2023-06-05 10:42:43.342819	411.74
114	25	7	16	2023-05-29 14:09:23.568858	2023-06-01 12:05:15.564534	174.83
115	8	20	10	2023-05-29 14:34:21.355014	2023-06-04 22:33:18.447286	379.96
116	1	12	18	2023-05-29 14:44:59.234198	2023-06-05 08:57:50.016323	405.54
117	12	10	3	2023-05-29 14:47:11.609233	2023-06-11 02:16:24.332213	748.72
118	7	29	15	2023-05-29 16:47:21.081039	2023-05-30 14:04:58.205262	53.23
119	4	1	3	2023-05-29 17:29:46.898441	2023-06-05 23:57:19.94455	436.15
120	3	21	20	2023-05-29 18:05:01.581049	2023-06-09 19:02:40.401383	662.40
121	22	27	1	2023-05-29 18:12:09.899892	2023-06-14 07:43:39.717541	933.81
122	7	20	20	2023-05-29 18:16:03.389742	2023-06-18 21:06:41.225334	1207.11
123	3	22	5	2023-05-29 21:06:24.403042	2023-06-07 04:09:13.171793	497.62
124	9	16	3	2023-05-29 22:49:40.95819	2023-05-30 19:37:55.183891	52.01
125	12	2	11	2023-05-29 23:17:00.594608	2023-06-06 19:19:22.002699	470.10
126	1	3	18	2023-05-30 00:20:18.387763	2023-06-11 03:24:50.850693	727.69
127	11	21	12	2023-05-30 01:51:59.889939	2023-06-15 22:42:03.253648	1012.09
128	6	7	2	2023-05-30 02:13:48.100034	2023-06-05 22:34:48.86531	410.88
129	1	28	5	2023-05-30 02:55:33.305095	2023-05-30 19:43:01.25681	41.98
130	17	16	13	2023-05-30 03:53:36.180651	2023-06-01 15:17:19.936537	148.49
131	25	29	6	2023-05-30 04:05:28.971982	2023-06-02 21:27:22.793763	223.41
132	2	5	13	2023-05-30 04:25:38.254583	2023-06-17 10:25:36.130602	1095.00
133	1	17	17	2023-05-30 05:11:55.695509	2023-06-15 07:44:52.116	966.37
134	19	25	7	2023-05-30 05:23:55.691703	2023-06-07 08:02:34.783093	486.61
135	18	27	10	2023-05-30 05:38:14.263324	2023-06-05 03:58:06.730248	355.83
136	28	21	15	2023-05-30 06:06:34.797044	2023-06-18 07:06:12.691597	1142.48
137	11	7	13	2023-05-30 06:22:01.026219	2023-06-08 05:43:04.032557	538.38
138	7	23	13	2023-05-30 07:10:00.832017	2023-06-16 11:03:58.527877	1029.75
139	25	16	1	2023-05-30 07:18:07.44904	2023-06-20 17:53:57.41186	1286.49
140	11	20	1	2023-05-30 07:22:53.832323	2023-06-22 22:52:38.468424	1418.74
141	17	24	2	2023-05-30 07:41:56.972815	2023-06-21 11:50:28.458023	1330.36
142	8	19	6	2023-05-30 09:15:41.532984	2023-06-11 11:48:53.804459	726.38
143	18	1	10	2023-05-30 09:32:41.423615	2023-06-06 19:49:56.153281	445.72
144	5	3	13	2023-05-30 10:57:20.734966	2023-06-08 00:26:19.930513	513.71
145	1	27	6	2023-05-30 11:06:00.628755	2023-06-01 21:18:11.896353	145.51
146	6	1	20	2023-05-30 12:25:25.245725	2023-06-03 14:35:39.041215	245.43
147	28	4	1	2023-05-30 12:32:58.317692	2023-06-06 03:39:41.773662	397.78
148	5	26	2	2023-05-30 14:03:00.5211	2023-06-16 04:45:26.496014	996.77
149	26	13	16	2023-05-30 14:14:38.656604	2023-06-16 13:15:12.825448	1017.52
150	18	16	2	2023-05-30 14:18:36.778338	2023-06-21 05:17:00.293735	1297.43
151	19	3	13	2023-05-30 14:24:07.979812	2023-06-15 13:54:19.812324	958.76
152	18	17	1	2023-05-30 14:46:04.022441	2023-06-19 05:56:50.091522	1177.95
153	13	26	1	2023-05-30 15:39:12.891517	2023-06-16 14:39:47.060361	1017.52
154	9	14	6	2023-05-30 15:45:23.267167	2023-06-13 15:00:36.462788	838.13
155	4	27	13	2023-05-30 17:46:50.725537	2023-06-04 17:21:03.616166	298.93
156	13	26	4	2023-05-30 18:55:25.173694	2023-06-16 17:55:59.342538	1017.52
157	3	20	14	2023-05-30 18:59:25.673917	2023-06-23 05:15:10.641224	1405.66
158	9	28	13	2023-05-30 19:14:30.903094	2023-06-17 07:41:49.808378	1051.14
159	23	12	15	2023-05-30 19:24:43.80231	2023-06-11 23:51:54.626934	731.13
160	22	29	2	2023-05-30 19:44:55.016475	2023-06-20 04:40:59.245645	1222.34
161	25	18	3	2023-05-30 20:01:48.444329	2023-06-03 10:01:02.760662	214.97
162	7	19	13	2023-05-30 20:38:16.610849	2023-06-10 17:12:49.694379	651.44
163	22	29	9	2023-05-30 21:06:55.145852	2023-06-20 06:02:59.375022	1222.34
164	27	28	7	2023-05-30 21:18:42.492822	2023-06-01 14:53:28.064261	103.95
165	17	4	12	2023-05-30 21:52:58.805758	2023-06-12 07:03:52.208955	742.95
166	12	9	4	2023-05-30 22:49:38.164084	2023-06-15 05:13:20.221618	915.99
167	14	24	14	2023-05-30 23:16:54.166765	2023-06-22 22:04:54.190761	1377.00
168	22	25	6	2023-05-30 23:19:39.58679	2023-06-18 19:40:51.242328	1130.88
169	6	25	10	2023-05-30 23:21:30.153205	2023-06-07 14:12:31.11436	457.13
170	1	8	12	2023-05-30 23:27:07.22345	2023-06-22 09:20:42.388326	1344.73
171	2	29	13	2023-05-31 00:01:59.807295	2023-06-05 17:22:28.202408	343.35
172	29	21	15	2023-05-31 00:15:42.185416	2023-06-22 09:45:36.527867	1343.75
173	20	4	13	2023-05-31 00:35:28.830012	2023-06-15 21:55:27.714269	953.33
174	21	15	18	2023-05-31 01:14:35.153099	2023-06-23 13:51:27.95662	1411.54
175	24	1	15	2023-05-31 01:37:05.603431	2023-06-07 00:17:51.735548	416.70
176	1	28	14	2023-05-31 01:37:17.357262	2023-05-31 18:24:45.308977	41.98
177	16	15	13	2023-05-31 01:49:21.90291	2023-06-22 13:01:42.894907	1348.01
178	21	5	2	2023-05-31 02:27:44.03966	2023-06-05 13:31:39.215531	327.66
179	18	22	12	2023-05-31 03:23:29.272903	2023-06-17 22:02:52.60115	1066.64
180	4	29	16	2023-05-31 05:19:01.745464	2023-06-09 23:55:30.023475	586.52
181	21	7	15	2023-05-31 05:27:13.929946	2023-06-21 21:37:15.836739	1300.42
182	29	7	20	2023-05-31 06:00:42.102844	2023-06-01 03:18:19.227067	53.23
183	12	3	13	2023-05-31 06:36:14.382493	2023-06-10 12:14:04.1487	614.08
184	25	9	15	2023-05-31 06:49:07.368666	2023-06-21 01:55:30.980167	1247.77
185	28	25	10	2023-05-31 06:50:00.552992	2023-06-04 11:09:29.491607	250.81
186	3	17	14	2023-05-31 07:19:15.454019	2023-06-04 07:03:15.640686	239.33
187	17	3	20	2023-05-31 07:36:37.570949	2023-06-04 07:20:37.757616	239.33
188	22	1	2	2023-05-31 08:18:59.3733	2023-06-17 18:56:32.433138	1046.56
189	24	7	3	2023-05-31 08:37:31.622552	2023-06-04 19:17:21.676131	266.66
190	27	26	5	2023-05-31 08:37:57.35404	2023-06-02 11:39:27.519589	127.56
191	3	25	9	2023-05-31 08:54:02.759815	2023-06-15 15:22:53.824281	916.20
192	22	7	3	2023-05-31 08:54:17.209649	2023-06-20 01:43:14.970212	1182.04
193	10	5	19	2023-05-31 09:00:58.973111	2023-06-27 04:04:50.527638	1607.66
194	24	7	9	2023-05-31 09:20:38.29946	2023-06-04 20:00:28.353039	266.66
195	2	21	1	2023-05-31 10:23:07.597761	2023-06-19 08:08:49.275327	1134.40
196	16	17	5	2023-05-31 10:40:17.755214	2023-06-02 22:04:01.5111	148.49
197	13	12	9	2023-05-31 10:49:33.064564	2023-06-16 17:29:15.863536	976.65
198	13	24	7	2023-05-31 10:59:06.879056	2023-06-25 13:15:46.082502	1505.69
199	28	5	19	2023-05-31 11:06:19.873802	2023-06-19 19:26:01.474774	1160.82
200	20	5	18	2023-05-31 12:29:49.537004	2023-06-24 08:14:15.496023	1429.35
201	6	29	18	2023-05-31 13:04:30.026292	2023-06-07 19:02:04.95803	434.90
202	13	16	3	2023-05-31 13:39:38.029973	2023-06-01 20:29:10.513496	77.06
203	25	9	18	2023-05-31 13:44:38.288634	2023-06-21 08:51:01.900135	1247.77
204	2	18	13	2023-05-31 13:53:30.706072	2023-06-10 16:26:52.376327	606.39
205	4	16	7	2023-05-31 13:58:00.116937	2023-06-14 21:08:57.993573	857.96
206	26	5	7	2023-05-31 14:06:07.014312	2023-06-17 04:48:32.989226	996.77
207	21	4	1	2023-05-31 14:53:17.686237	2023-06-13 08:02:26.058408	762.88
208	15	2	17	2023-05-31 15:14:36.728222	2023-06-06 21:23:58.623441	375.39
209	5	10	15	2023-05-31 15:32:00.650464	2023-06-27 10:35:52.204991	1607.66
210	12	15	16	2023-05-31 17:11:45.80705	2023-06-10 20:13:29.741972	607.57
211	26	15	9	2023-05-31 17:17:15.178601	2023-06-08 18:19:29.715986	482.59
212	4	9	4	2023-05-31 17:35:47.498647	2023-06-14 12:30:21.546404	827.27
213	2	11	15	2023-05-31 18:02:11.763366	2023-06-04 04:08:50.24604	205.28
214	23	25	17	2023-05-31 18:28:17.129798	2023-06-18 06:14:38.214294	1049.43
215	28	17	3	2023-05-31 18:47:14.874621	2023-06-16 16:00:27.732188	953.05
216	6	13	10	2023-05-31 18:52:46.169191	2023-06-16 01:36:43.584002	916.83
217	11	12	8	2023-05-31 18:55:57.86312	2023-06-09 07:43:46.160625	511.99
218	6	7	4	2023-05-31 19:16:07.017008	2023-06-07 15:37:07.782284	410.88
219	25	18	6	2023-05-31 19:25:05.918905	2023-06-04 09:24:20.235238	214.97
220	13	18	4	2023-05-31 19:58:10.162747	2023-06-22 23:14:51.458455	1328.20
221	2	15	1	2023-05-31 20:02:51.127132	2023-06-07 02:12:13.022351	375.39
222	25	22	6	2023-05-31 20:46:02.613089	2023-06-19 17:07:14.268627	1130.88
223	8	3	12	2023-05-31 21:10:33.385176	2023-06-22 14:38:25.798952	1303.66
224	4	23	13	2023-05-31 21:38:40.693728	2023-06-11 15:04:00.091948	643.56
225	28	8	20	2023-05-31 22:36:44.56401	2023-06-22 15:44:01.851694	1302.80
226	28	11	13	2023-05-31 22:49:34.31581	2023-06-07 05:15:58.37881	376.10
227	26	9	6	2023-05-31 22:52:49.612266	2023-06-16 15:41:00.365141	942.01
228	20	19	12	2023-05-31 22:54:07.542755	2023-06-10 10:39:38.04675	569.40
229	4	14	9	2023-05-31 22:56:45.577167	2023-06-14 06:05:51.574158	797.88
230	8	6	15	2023-05-31 23:55:07.376457	2023-06-22 07:12:23.092849	1278.22
231	25	24	6	2023-06-01 00:41:57.716029	2023-06-03 23:37:04.794268	177.30
232	13	10	15	2023-06-01 01:26:32.588954	2023-06-27 12:46:41.42707	1588.34
233	1	10	8	2023-06-01 03:13:17.517446	2023-06-08 05:47:44.750899	426.44
234	27	14	11	2023-06-01 03:34:44.101016	2023-06-19 10:15:37.794156	1096.70
235	8	7	5	2023-06-01 03:36:49.670198	2023-06-23 22:24:58.759901	1367.01
236	19	9	8	2023-06-01 03:50:25.597007	2023-06-21 14:40:21.961308	1227.08
237	8	14	20	2023-06-01 04:02:15.576147	2023-06-11 22:55:46.789989	647.23
238	28	10	14	2023-06-01 04:54:38.314777	2023-06-08 15:44:26.735792	447.08
239	26	19	9	2023-06-01 05:19:11.079282	2023-06-08 18:59:02.259781	454.16
240	11	3	15	2023-06-01 05:26:19.612882	2023-06-08 05:28:32.606408	420.09
241	13	15	17	2023-06-01 06:18:22.906677	2023-06-24 15:30:17.453313	1403.00
242	1	8	19	2023-06-01 07:02:27.102717	2023-06-23 16:56:02.267593	1344.73
243	29	12	15	2023-06-01 07:14:51.171074	2023-06-10 05:19:36.51835	535.20
244	27	7	3	2023-06-01 09:08:22.51443	2023-06-05 12:25:53.809115	248.23
245	18	27	11	2023-06-01 09:26:45.381085	2023-06-07 07:46:37.848009	355.83
246	20	24	11	2023-06-01 09:28:58.555926	2023-06-18 22:58:47.403967	1053.74
247	19	16	12	2023-06-01 10:33:39.764745	2023-06-22 06:14:52.751374	1249.22
248	6	2	4	2023-06-01 10:38:49.236988	2023-06-04 06:59:18.870136	170.85
249	22	24	20	2023-06-01 10:50:13.00368	2023-06-23 01:48:15.008884	1297.42
250	29	28	18	2023-06-01 11:55:39.015013	2023-06-04 23:39:18.252369	209.32
251	1	16	12	2023-06-01 12:34:31.266515	2023-06-20 00:17:55.194047	1109.31
252	8	29	14	2023-06-01 13:29:12.287733	2023-06-25 05:33:15.974942	1420.17
253	10	18	15	2023-06-01 14:14:54.628877	2023-06-10 21:38:25.561055	558.48
254	21	22	15	2023-06-01 15:06:05.460398	2023-06-04 09:03:29.258156	164.89
255	20	29	20	2023-06-01 15:34:01.322942	2023-06-22 14:36:22.794425	1257.60
256	18	9	4	2023-06-01 16:12:28.644259	2023-06-22 18:18:50.299947	1265.27
257	14	20	13	2023-06-01 17:04:02.272425	2023-06-17 10:53:00.851155	944.54
258	14	13	8	2023-06-01 17:46:52.681481	2023-06-14 15:56:18.833491	775.39
259	12	26	11	2023-06-01 17:55:06.152411	2023-06-03 23:46:05.850368	134.62
260	24	13	13	2023-06-01 18:40:13.039159	2023-06-26 20:56:52.242605	1505.69
261	24	8	4	2023-06-01 18:41:02.438824	2023-06-23 02:09:20.720964	1278.68
262	2	11	8	2023-06-01 19:00:23.588333	2023-06-05 05:07:02.071007	205.28
263	25	9	14	2023-06-01 19:13:04.298797	2023-06-22 14:19:27.910298	1247.77
264	29	4	20	2023-06-01 20:15:57.043077	2023-06-11 14:52:25.321088	586.52
265	6	29	6	2023-06-01 21:06:13.800686	2023-06-09 03:03:48.732424	434.90
266	13	17	5	2023-06-01 21:29:26.005706	2023-06-05 12:17:36.008098	217.01
267	17	28	9	2023-06-01 22:05:47.631632	2023-06-17 19:19:00.489199	953.05
268	27	11	5	2023-06-01 22:16:37.838907	2023-06-08 10:47:46.92275	391.30
269	13	28	2	2023-06-01 22:23:05.588064	2023-06-21 00:26:21.336433	1145.14
270	5	27	4	2023-06-01 22:28:48.259862	2023-06-20 03:08:56.776817	1091.67
\.


--
-- Name: cidades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yokuny
--

SELECT pg_catalog.setval('public.cidades_id_seq', 29, true);


--
-- Name: comodidades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yokuny
--

SELECT pg_catalog.setval('public.comodidades_id_seq', 10, true);


--
-- Name: companhias_aereas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yokuny
--

SELECT pg_catalog.setval('public.companhias_aereas_id_seq', 20, true);


--
-- Name: hoteis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yokuny
--

SELECT pg_catalog.setval('public.hoteis_id_seq', 147, true);


--
-- Name: voos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: yokuny
--

SELECT pg_catalog.setval('public.voos_id_seq', 270, true);


--
-- Name: cidades cidades_nome_key; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.cidades
    ADD CONSTRAINT cidades_nome_key UNIQUE (nome);


--
-- Name: cidades cidades_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.cidades
    ADD CONSTRAINT cidades_pkey PRIMARY KEY (id);


--
-- Name: comodidades comodidades_nome_key; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.comodidades
    ADD CONSTRAINT comodidades_nome_key UNIQUE (nome);


--
-- Name: comodidades comodidades_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.comodidades
    ADD CONSTRAINT comodidades_pkey PRIMARY KEY (id);


--
-- Name: companhias_aereas companhias_aereas_nome_key; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.companhias_aereas
    ADD CONSTRAINT companhias_aereas_nome_key UNIQUE (nome);


--
-- Name: companhias_aereas companhias_aereas_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.companhias_aereas
    ADD CONSTRAINT companhias_aereas_pkey PRIMARY KEY (id);


--
-- Name: hoteis hoteis_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hoteis
    ADD CONSTRAINT hoteis_pkey PRIMARY KEY (id);


--
-- Name: hotel_comodidades hotel_comodidades_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hotel_comodidades
    ADD CONSTRAINT hotel_comodidades_pkey PRIMARY KEY (hotel_id, comodidade_id);


--
-- Name: voos voos_pkey; Type: CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT voos_pkey PRIMARY KEY (id);


--
-- Name: voos calcular_hora_chegada_trigger; Type: TRIGGER; Schema: public; Owner: yokuny
--

CREATE TRIGGER calcular_hora_chegada_trigger BEFORE INSERT ON public.voos FOR EACH ROW EXECUTE FUNCTION public.calcular_hora_chegada_trigger();


--
-- Name: voos calcular_preco_trigger; Type: TRIGGER; Schema: public; Owner: yokuny
--

CREATE TRIGGER calcular_preco_trigger BEFORE INSERT ON public.voos FOR EACH ROW EXECUTE FUNCTION public.calcular_preco_trigger();


--
-- Name: hoteis fk_cidade; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hoteis
    ADD CONSTRAINT fk_cidade FOREIGN KEY (cidade_id) REFERENCES public.cidades(id);


--
-- Name: voos fk_cidade_destino; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT fk_cidade_destino FOREIGN KEY (cidade_destino_id) REFERENCES public.cidades(id);


--
-- Name: voos fk_cidade_partida; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT fk_cidade_partida FOREIGN KEY (cidade_partida_id) REFERENCES public.cidades(id);


--
-- Name: hotel_comodidades fk_comodidade; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hotel_comodidades
    ADD CONSTRAINT fk_comodidade FOREIGN KEY (comodidade_id) REFERENCES public.comodidades(id);


--
-- Name: voos fk_companhia_aerea; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT fk_companhia_aerea FOREIGN KEY (companhia_aerea_id) REFERENCES public.companhias_aereas(id);


--
-- Name: hotel_comodidades fk_hotel; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hotel_comodidades
    ADD CONSTRAINT fk_hotel FOREIGN KEY (hotel_id) REFERENCES public.hoteis(id);


--
-- Name: hoteis hoteis_cidade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hoteis
    ADD CONSTRAINT hoteis_cidade_id_fkey FOREIGN KEY (cidade_id) REFERENCES public.cidades(id);


--
-- Name: hotel_comodidades hotel_comodidades_comodidade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hotel_comodidades
    ADD CONSTRAINT hotel_comodidades_comodidade_id_fkey FOREIGN KEY (comodidade_id) REFERENCES public.comodidades(id);


--
-- Name: hotel_comodidades hotel_comodidades_hotel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.hotel_comodidades
    ADD CONSTRAINT hotel_comodidades_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES public.hoteis(id);


--
-- Name: voos voos_cidade_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT voos_cidade_destino_id_fkey FOREIGN KEY (cidade_destino_id) REFERENCES public.cidades(id);


--
-- Name: voos voos_cidade_partida_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT voos_cidade_partida_id_fkey FOREIGN KEY (cidade_partida_id) REFERENCES public.cidades(id);


--
-- Name: voos voos_companhia_aerea_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: yokuny
--

ALTER TABLE ONLY public.voos
    ADD CONSTRAINT voos_companhia_aerea_id_fkey FOREIGN KEY (companhia_aerea_id) REFERENCES public.companhias_aereas(id);


--
-- PostgreSQL database dump complete
--

