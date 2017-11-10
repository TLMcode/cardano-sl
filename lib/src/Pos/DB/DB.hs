{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE CPP                 #-}
{-# LANGUAGE TypeFamilies        #-}

-- | Higher-level DB functionality.

module Pos.DB.DB
       ( initNodeDBs
       , sanityCheckDB
       , gsAdoptedBVDataDefault
       ) where

import           Universum

import           Control.Monad.Catch (MonadMask)
import           System.Wlog (WithLogger)

import           Pos.Context.Functions (genesisBlock0)
import           Pos.Core (BlockVersionData, HasConfiguration, headerHash)
import           Pos.DB.Block (prepareBlockDB)
import           Pos.DB.Class (MonadDB, MonadDBRead (..))
import           Pos.DB.Misc (prepareMiscDB)
import           Pos.GState.GState (prepareGStateDB, sanityCheckGStateDB)
import           Pos.Lrc.DB (prepareLrcDB)
import           Pos.Ssc.Configuration (HasSscConfiguration)
import           Pos.Update.DB (getAdoptedBVData)
import           Pos.Util (inAssertMode)

-- | Initialize DBs if necessary.
initNodeDBs
    :: forall ctx m.
       ( MonadReader ctx m
       , MonadDB m
       , HasConfiguration
       , HasSscConfiguration
       )
    => m ()
initNodeDBs = do
    let initialTip = headerHash genesisBlock0
    prepareBlockDB genesisBlock0
    prepareGStateDB initialTip
    prepareLrcDB
    prepareMiscDB

sanityCheckDB ::
       ( MonadMask m
       , WithLogger m
       , MonadDBRead m
       , MonadReader ctx m
       )
    => m ()
sanityCheckDB = inAssertMode sanityCheckGStateDB

----------------------------------------------------------------------------
-- MonadGState instance
----------------------------------------------------------------------------

gsAdoptedBVDataDefault :: MonadDBRead m => m BlockVersionData
gsAdoptedBVDataDefault = getAdoptedBVData
