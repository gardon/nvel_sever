module Models exposing (..)

import Menu exposing (..)
import Dict exposing (Dict)
import Image exposing (Image)
import Date exposing (Date)

type alias Model =
  { chapters : Maybe (Dict String Chapter)
  , siteInformation : SiteInformation
  , pageData : PageData
  , backendConfig : BackendConfig
  , menu : List MenuItem
  , route : Route
  }

type alias Chapter =
  { title : String
  , field_description: String
  , nid : String
  , content: List Section
  , index: Int
  , thumbnail: Image
  , authors: List String
  , date: Date
  }

type SectionType
  = SingleImage
  | FullWidthSingleImage

type alias Section =
    { sectionType : SectionType
    , image : Image }

type alias BackendConfig =
    { backendURL : String }

type alias SiteInformation = 
    { title : String 
    , description : String
    , facebook_page : String
    , instagram_handle : String
    , deviantart_profile : String
    }

type alias PageData = 
    { title : String
    }

type Environment = Local

type alias ChapterId = String

type Route
    = HomeRoute
    | ChaptersRoute
    | ChapterRoute ChapterId
    | NotFoundRoute

siteInformationEndpoint = "nvel_base?_format=json"
chapterListEndpoint = "chapters?_format=json"
chapterContentEndpoint = "chapters"


