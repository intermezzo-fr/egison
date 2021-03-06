{- |
Module      : Language.Egison
Copyright   : Satoshi Egi
Licence     : MIT

This is the top module of Egison.
-}

module Language.Egison
       ( module Language.Egison.Types
       , module Language.Egison.Parser
       , module Language.Egison.Primitives
       -- * Eval Egison expressions
       , evalEgisonExpr
       , evalEgisonTopExpr
       , evalEgisonTopExprs
       , evalEgisonTopExprsTestOnly
       , runEgisonExpr
       , runEgisonTopExpr
       , runEgisonTopExprs
       , runEgisonTopExprsNoIO
       -- * Load Egison files
       , loadEgisonLibrary
       , loadEgisonFile
       -- * Environment
       , initialEnv
       , initialEnvNoIO
       -- * Information
       , version
       ) where

import Data.Version
import qualified Paths_egison as P

import Language.Egison.Types
import Language.Egison.Parser
import Language.Egison.Primitives
import Language.Egison.Core

-- |Version number
version :: Version
version = P.version

-- |eval an Egison expression
evalEgisonExpr :: Env -> EgisonExpr -> IO (Either EgisonError EgisonValue)
evalEgisonExpr env expr = fromEgisonM $ evalExprDeep env expr

-- |eval an Egison top expression
evalEgisonTopExpr :: Env -> EgisonTopExpr -> IO (Either EgisonError Env)
evalEgisonTopExpr env exprs = fromEgisonM $ evalTopExpr env exprs

-- |eval Egison top expressions
evalEgisonTopExprs :: Env -> [EgisonTopExpr] -> IO (Either EgisonError Env)
evalEgisonTopExprs env exprs = fromEgisonM $ evalTopExprs env exprs

-- |eval Egison top expressions and execute test expressions
evalEgisonTopExprsTestOnly :: Env -> [EgisonTopExpr] -> IO (Either EgisonError Env)
evalEgisonTopExprsTestOnly env exprs = fromEgisonM $ evalTopExprsTestOnly env exprs

-- |eval an Egison expression. Input is a Haskell string.
runEgisonExpr :: Env -> String -> IO (Either EgisonError EgisonValue)
runEgisonExpr env input = fromEgisonM $ readExpr input >>= evalExprDeep env

-- |eval an Egison top expression. Input is a Haskell string.
runEgisonTopExpr :: Env -> String -> IO (Either EgisonError Env)
runEgisonTopExpr env input = fromEgisonM $ readTopExpr input >>= evalTopExpr env

-- |eval Egison top expressions. Input is a Haskell string.
runEgisonTopExprs :: Env -> String -> IO (Either EgisonError Env)
runEgisonTopExprs env input = fromEgisonM $ readTopExprs input >>= evalTopExprs env

-- |eval Egison top expressions without IO. Input is a Haskell string.
runEgisonTopExprsNoIO :: Env -> String -> IO (Either EgisonError Env)
runEgisonTopExprsNoIO env input = fromEgisonM $ readTopExprs input >>= evalTopExprsNoIO env

-- |load an Egison file
loadEgisonFile :: Env -> FilePath -> IO (Either EgisonError Env)
loadEgisonFile env path = evalEgisonTopExpr env (LoadFile path)

-- |load an Egison library
loadEgisonLibrary :: Env -> FilePath -> IO (Either EgisonError Env)
loadEgisonLibrary env path = evalEgisonTopExpr env (Load path)

-- |Environment that contains core libraries
initialEnv :: IO Env
initialEnv = do
  env <- primitiveEnv
  ret <- evalEgisonTopExprs env $ map Load coreLibraries
  case ret of
    Left err -> do
      print . show $ err
      return env
    Right env' -> return env'

-- |Environment that contains core libraries without IO primitives
initialEnvNoIO :: IO Env
initialEnvNoIO = do
  env <- primitiveEnvNoIO 
  ret <- evalEgisonTopExprs env $ map Load coreLibraries
  case ret of
    Left err -> do
      print . show $ err
      return env
    Right env' -> return env'

coreLibraries :: [String]
coreLibraries =
  [ "lib/core/base.egi"
  , "lib/core/collection.egi"
  , "lib/core/order.egi"
  , "lib/core/number.egi"
  , "lib/core/io.egi"
  , "lib/core/random.egi"
  , "lib/core/array.egi"
  , "lib/core/string.egi"
  ]
