import Std.Internal.Http

open Std.Internal.IO.Async
open Std Http Server

def h := "Hello, World!"

def mkBlob (n : Nat) : ByteArray := Id.run do
  let mut bs := ByteArray.emptyWithCapacity n
  for _ in [:n] do
    bs := bs.push 0x58
  return bs

instance : Handler ByteArray where
  onRequest blob req :=
    let path := toString req.line.uri.path

    if path == "/plaintext" then
      Response.ok |>.text h
    else if path == "/blob" then
      Response.ok |>.bytes blob
    else
      Response.notFound |>.text "Not Found"

def main : IO Unit := do
  let blob := mkBlob (1024 * 1024)

  Async.block do
    let server ← Server.serve (.v4 ⟨.ofParts 0 0 0 0, 4000⟩) blob
      { maxConnections := 0, maxRequests := 10_000_000, generateDate := false, serverName := none }
    server.waitShutdown
