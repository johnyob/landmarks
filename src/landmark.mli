(* This file is released under the terms of an MIT-like license.     *)
(* See the attached LICENSE file.                                    *)
(* Copyright 2016 by LexiFi.                                         *)

type landmark
type counter
type sampler

val clock: unit -> Int64.t

exception LandmarkFailure of string

val register: string -> landmark
(** [register name] registers a new landmark.
    /!\ Should always be called at top-level /!\ *)

val register_counter: string -> counter
(** [register_counter name] registers a new counter.
    /!\ Should always be called at top-level /!\ *)

val register_sampler: string -> sampler
(** [register_counter name] registers a new sampler. *)

val increment: ?times:int -> counter -> unit
val sample: sampler -> float -> unit

val enter: landmark -> unit
(** Begins a landmark block.
    /!\ Landmark blocks should be well-nested, otherwise a failure will be
        raised during profiling. *)

val exit: landmark -> unit
(** Ends a landmark block. *)

val wrap: landmark -> ('a -> 'b) -> 'a -> 'b
(** Puts landmark blocks around a function (and close the block and re-raise
    in case of uncaught exception). *)

val unsafe_wrap: landmark -> ('a -> 'b) -> 'a -> 'b
(** Puts landmark blocks around a function without catching exceptions. *)

val landmark_of_id: int -> landmark

val reset: unit -> unit
(** Reset the profiling information gathered by the current process. *)

val export: unit -> Landmark_graph.graph
(** Export the profiling information of the current process. *)

val export_and_reset: unit -> Landmark_graph.graph
(** Export the profiling information of the current process; then reset 
    internal state. *)

(** Aggregate the profiling information (exported by another process) to the
    current one. This should is used by the master process to merge exported
    profiles of slaves. *)
val merge: Landmark_graph.graph -> unit

(** These functions allow to check if the profiling is ongoing. *)
val profiling: unit -> bool

type profile_output =
  | Silent
  | Temporary 
  | Channel of out_channel

type profile_format = 
  | JSON
  | Textual

type profiling_options = {
  debug : bool;
  gc_stat: bool;
  sys_time : bool;
  output : profile_output;
  format : profile_format
}

val default_options: profiling_options
val set_profiling_options: profiling_options -> unit

val start_profiling: ?profiling_options:profiling_options ->  unit -> unit

val stop_profiling: unit -> unit

