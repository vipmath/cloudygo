/* Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


CREATE TABLE IF NOT EXISTS models (
  model_id integer primary key,
  name text not null,
  raw_name text not null,
  bucket text not null,
  num integer not null,

  last_updated integer not null,
  creation integer not null,
  training_time_m integer not null,

  num_games integer not null,
  num_stats_games integer not null,
  num_eval_games integer not null
);


CREATE TABLE IF NOT EXISTS games (
  game_num integer primary key,
  filename text not null,
  model_id integer not null,

  black_won boolean not null,
  result text not null,
  num_moves integer not null
);


CREATE TABLE IF NOT EXISTS game_stats (
  game_num integer primary key,
  model_id integer not null,

  black_won boolean not null,
  result text not null,
  result_margin integer not null, /* 0 if resign for now */

  num_moves integer,
  early_moves text,
  early_moves_canonical text,

  number_of_visits_black integer,
  number_of_visits_white integer,

  number_of_visits_early_black integer,
  number_of_visits_early_white integer,

  unluckiness_black float,
  unluckiness_white float,

  resign_threshold float,
  bleakest_eval_black float,
  bleakest_eval_white float
);


CREATE TABLE IF NOT EXISTS model_stats (
  model_id integer not null,
  perspective text not null, /* "Black", "White", "All" */

  num_games integer not null,
  stats_games integer not null,

  wins integer,
  wins_by_resigns integer,
  wins_by_result integer,
  sum_wins_result integer,

  /* TODO(sethtroisi): rename holdout */
  hold_out_resigns integer,
  bad_resigns integer,

  /* Over games won by perspective */
  num_moves integer,
  number_of_visits integer,

  /* TODO(sethtroisi): figure out a better way to represent win / lose */
  number_of_visits_early_moves integer,
  sum_unluckiness float,

  favorite_openings text,

  PRIMARY KEY (model_id, perspective)

  /* TODO(sethtroisi): distributions */
  /* num_moves, */
  /* heatmap of openings, common openings, bleakest_eval, win amount */
);


CREATE TABLE IF NOT EXISTS eval_models (
  model_id_1 integer not null,
  model_id_2 integer not null,

  /* average of rank (or model_1_rank */
  rankings float,
  std_err float,

  games integer not null,

  m1_black_games integer,
  m1_black_wins integer,

  m1_white_games integer,
  m1_white_wins integer,

  PRIMARY KEY (model_id_1, model_id_2)
);


CREATE TABLE IF NOT EXISTS eval_games (
  /* time _ model_1 _ model_2 _ number */
  /* model_1 plays white is most games */
  eval_num integer not null,
  filename text not null,

  model_id_1 integer not null,
  model_id_2 integer,

  black_won boolean,
  result text,
  moves integer,

  PRIMARY KEY (eval_num, model_id_1)
);


CREATE TABLE IF NOT EXISTS position_eval_part (
  model_id integer,
  cord integer,
  type text,
  name text,

  policy float,
  value float,
  n integer,
  sgf text,

  PRIMARY KEY (model_id, cord, type, name)
);


CREATE TABLE IF NOT EXISTS position_setups (
  bucket text,
  name text,
  sgf text,

  PRIMARY KEY (bucket, name)
);


CREATE INDEX IF NOT EXISTS bucket_index ON models (bucket);

CREATE INDEX IF NOT EXISTS game_model_index ON games (model_id);
CREATE INDEX IF NOT EXISTS game_stats_model_index ON game_stats (model_id);

CREATE INDEX IF NOT EXISTS eval_models_model_index_1 on eval_models (model_id_1);
CREATE INDEX IF NOT EXISTS eval_models_model_index_2 on eval_models (model_id_2);

CREATE INDEX IF NOT EXISTS eval_games_eval_num on eval_games (eval_num);
CREATE INDEX IF NOT EXISTS eval_games_model_index_1 on eval_games (model_id_1);
CREATE INDEX IF NOT EXISTS eval_games_model_index_2 on eval_games (model_id_2);

