{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}


module SendDbReq
  ( sendReq,
  )
where

import           Control.Exception
import           Control.Monad.IO.Class
import           Control.Monad.Trans.Class
import           Control.Monad.Trans.Except
import           Control.Monad.Trans.Reader
import           Data.Aeson
import qualified Data.Text.Lazy             as TL
import           Network.HTTP.Req


sendReq :: Option 'Https -> TL.Text -> ExceptT Int (ReaderT (Url 'Https) IO) Value
sendReq queryScheme searchTable = do
  myUri <- lift ask
  result <- liftIO
              ( try $ runReq defaultHttpConfig $ do
                  req
                    Network.HTTP.Req.GET
                    (myUri /~ searchTable)
                    NoReqBody
                    jsonResponse
                    queryScheme
                :: IO (Either HttpException (JsonResponse Value))
              )
  either (const $ throwE 500) (pure . responseBody) result
