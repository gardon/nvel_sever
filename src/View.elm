module View exposing (..)

import Html exposing (..)
import Svg exposing (svg,path)
import Html.Attributes exposing (..)
import Svg.Attributes exposing (xmlSpace,d,viewBox)
import Html.Events exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Menu exposing (..)
import Dict exposing (Dict)
import Image exposing (Image, Derivative)
import Skeleton exposing (..)
import Date.Format

import View.Attributes exposing (..)

viewHome : Model -> List (Html Msg)
viewHome model =
  case model.chapters of
    Nothing ->
      [ text "Loading chapters..."]

    Just chapters ->
      let 
          list = sortChapterList chapters

          firstrow = 
            case List.head (List.reverse list) of
              Nothing ->
                skeletonRow [] []

              Just current ->
                case List.head list of
                  Nothing ->
                    skeletonRow [] [ viewChapterFeaturedCurrent current ]

                  Just first ->
                    if current == first then
                        skeletonRow [] [ viewChapterFeaturedCurrent current ]
                    else 
                        skeletonRow [] [ viewChapterFeaturedCurrent current, viewChapterFeaturedFirst first ]


          secondrow = skeletonRow [ class "center chapters-button" ] 
              [ linkButtonBig "chapters" "List all chapters"
              ]

          thirdrow = skeletonRow []
              [ mailchimpBlock model
              , facebookFeed model
              --, instagramFeed model
              ]

      in
          [ div [] 
              [ firstrow 
              , secondrow
              , thirdrow
              ]
          ]

facebookFeed : Model -> Html msg
facebookFeed model =
  let
    page = model.siteInformation.facebook_page
    title = model.siteInformation.title
      
  in
    div (skeletonGridSize SixColumns)
      [ div 
        [ class "fb-page"
        , dataAttr "href" ("https://www.facebook.com/" ++ page ++ "/")
        , dataAttr "small-header" "false" 
        , dataAttr "adapt-container-width" "true" 
        , dataAttr "hide-cover" "false" 
        , dataAttr "show-facepile" "false"
        , dataAttr "width" "300"
        ]
        [ blockquote 
          [ Html.Attributes.cite "https://www.facebook.com/abismos.oficial/" 
          , class "fb-xfbml-parse-ignore" 
          ]
          [ a [ href "https://www.facebook.com/abismos.oficial/" ] [ text title ] ]
        ]
      ]

mailchimpBlock : Model -> Html msg
mailchimpBlock model = 
  let 
    mailchimp_action = "//abismos.us12.list-manage.com/subscribe/post?u=3d03ee122031fb9d8b086b942&amp;id=35a44ac040"
  in 
    div (skeletonGridSize SixColumns)
      [ div [ id "mc_embed_signup" ]
        [ Html.form 
          [ action mailchimp_action
          , method "post"
          , id "mc-embedded-subscribe-form"
          , name "mc-embedded-subscribe-form"
          , class "validate"
          , target "_blank"
          , attribute "novalidate" ""
          , attribute "_lpchecked" "1"
          ]
          [ div [ id "mc_embed_signup_scroll" ]
            [ input 
              [ value ""
              , name "EMAIL"
              , class "email"
              , id "mce-EMAIL"
              , placeholder "E-mail"
              , attribute "required" ""
              , type_ "email"
              ] []
            , div [ style [ ("position", "absolute"), ("left", "-5000px") ], attribute "aria-hidden" "true" ]
                [ input [ name "b_3d03ee122031fb9d8b086b942_35a44ac040", tabindex -1, value "", type_ "text" ] []
                ]
            , div [ class "clear" ]
                [ input [ value "Assinar", name "subscribe", id "mc-embedded-subscribe", class "button", type_ "submit" ] []
                ]
            ]
          ]
        ]
      ]
    
            
viewChapterList : Maybe (Dict String Chapter) -> List (Html Msg)
viewChapterList chapters = 
  case chapters of 
    Nothing -> 
        [ text "Loading chapters..."]

    Just chapters -> 
        [ div [ class "container" ] (List.map viewChapterListItem (sortChapterList chapters)) ]

sortChapterList : Dict String Chapter -> List Chapter
sortChapterList chapters = 
  List.sortBy .index (Dict.values chapters)

viewChapterFeatured : String -> String -> Chapter -> Html Msg
viewChapterFeatured caption featured_class chapter = 
  let 
      chapterPath = "/chapters/" ++ chapter.nid
      chapterNumber = "#" ++ (toString chapter.index) ++ " "

  in
      div ([ class ("chapter-featured " ++ featured_class), onLinkClick (ChangeLocation chapterPath)] ++ skeletonGridSize SixColumns)
        [ viewImage [] chapter.featured_image
        , div [ class "image-overlay" ] 
          [ h3 [] [ text caption ] 
          , h2 [] [ span [] [ text chapterNumber ], text chapter.title ]
        ]
        , div [ class "inner" ]
          [ linkButtonPrimary chapterPath "Read it"
          , div [ class "description"] [ text chapter.field_description ]
          , div [ class "author" ] [ text (String.concat chapter.authors) ]
          , div [ class "date" ] [ text (Date.Format.format "%Y %b %e" chapter.date)]
          ]
        ]

viewChapterFeaturedCurrent : Chapter -> Html Msg
viewChapterFeaturedCurrent chapter =
  viewChapterFeatured "Current chapter" "current-chapter" chapter

viewChapterFeaturedFirst : Chapter -> Html Msg
viewChapterFeaturedFirst chapter =
  viewChapterFeatured "Start from the beginning" "first-chapter" chapter

linkButtonPrimary : String -> String -> Html Msg
linkButtonPrimary path title = 
  linkButton [ class "button-primary" ] path title

linkButton : List (Attribute Msg) -> String -> String -> Html Msg
linkButton attr path title = 
  a ([ href path, onLinkClick (ChangeLocation path), class "button" ] ++ attr) [ text title ]

linkButtonBig : String -> String -> Html Msg 
linkButtonBig path title = 
  linkButton [ class "big" ] path title

viewChapterListItem : Chapter -> Html Msg
viewChapterListItem chapter =
  let 
      chapterPath = "/chapters/" ++ chapter.nid
      chapterNumber = "#" ++ (toString chapter.index) ++ ": "
  in
      div [ class "chapter-list-item"]
        [
          h3 [] [ text chapterNumber ]
        , h2 [] [ a [ href chapterPath, onLinkClick (ChangeLocation chapterPath) ] [ text chapter.title ] ]
        , div [] [ text chapter.field_description ]
        , viewImage [] chapter.thumbnail
        , div [] [ text (String.concat chapter.authors) ]
        , div [] [ text (Date.Format.format "%Y %b %e" chapter.date)]
        ]

viewChapter : Chapter -> Html Msg
viewChapter chapter = 
    div []
        ( [ skeletonRowOneCol [] [ h1 [] [ text chapter.title ] ]
        ] ++ viewChapterContent chapter.content )

viewChapterContent : List Section -> List (Html msg)
viewChapterContent model =
   (List.map viewSection model)

viewSection : Section -> Html msg
viewSection model =
    case model.sectionType of 
      SingleImage ->
        div [] []  

      FullWidthSingleImage ->
        skeletonRowFullWidth [] [ viewImage [ class "u-full-width", sizes [ "100w" ] ] model.image ]

viewImage : List (Attribute msg) -> Image -> Html msg
viewImage attributes image =
  img ( attributes ++ 
    [ src image.uri
    , width image.width
    , height image.height
    , alt image.alt
    , title image.title
    , srcset image.derivatives 
    ]) []

viewMenu : List MenuItem -> Html Msg 
viewMenu menu =
  nav [ class "navbar"] [
      ul [ class "navbar-list" ] (List.map viewMenuItem menu)
  ]

viewMenuItem : MenuItem -> Html Msg
viewMenuItem item =
  li [ class "navbar-item" ] [ 
      a [ href item.path, onLinkClick (ChangeLocation item.path), class "navbar-link" ] [ text item.title ]
  ]

viewSocialLinks : Model -> Html Msg
viewSocialLinks model =
  ul [ class "social-links" ] 
    [ if model.siteInformation.facebook_page == "" then text "" else li [ class "social-links-item facebook" ] [ viewFacebookPageLink model.siteInformation.facebook_page ]
    , if model.siteInformation.instagram_handle == "" then text "" else li [ class "social-links-item instagram" ] [ viewInstagramLink model.siteInformation.instagram_handle ]
    , if model.siteInformation.deviantart_profile == "" then text "" else li [ class "social-links-item deviantart" ] [ viewDeviantArtLink model.siteInformation.deviantart_profile ]
    ]

viewFacebookPageLink : String -> Html msg
viewFacebookPageLink handle =
  a [ href ("http://www.facebook.com/" ++ handle), class "social-link facebook external-link", target "_blank" ] 
    [ viewSocialIcon FacebookIcon
    , text "Facebook"
    ]

viewInstagramLink : String -> Html msg
viewInstagramLink handle =
  a [ href ("http://instagram.com/" ++ handle), class "social-link instagram external-link", target "_blank" ] 
    [ viewSocialIcon InstagramIcon
    , text "Instagram" 
    ]

viewDeviantArtLink : String -> Html msg
viewDeviantArtLink handle =
  a [ href ("http://" ++ handle ++ ".deviantart.com/"), class "social-link deviantart external-link", target "_blank" ] 
    [ viewSocialIcon DeviantArtIcon
    , text "DeviantArt" 
  ]

viewSocialIcon : SocialIconType -> Html msg
viewSocialIcon social =
  let svgpath = 
    case social of
      FacebookIcon ->
        "M22.675 0h-21.35c-.732 0-1.325.593-1.325 1.325v21.351c0 .731.593 1.324 1.325 1.324h11.495v-9.294h-3.128v-3.622h3.128v-2.671c0-3.1 1.893-4.788 4.659-4.788 1.325 0 2.463.099 2.795.143v3.24l-1.918.001c-1.504 0-1.795.715-1.795 1.763v2.313h3.587l-.467 3.622h-3.12v9.293h6.116c.73 0 1.323-.593 1.323-1.325v-21.35c0-.732-.593-1.325-1.325-1.325z"
      InstagramIcon ->
        "M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"
      DeviantArtIcon ->
        "M20 4.364v-4.364h-4.364l-.435.439-2.179 4.124-.647.437h-7.375v6h4.103l.359.404-4.462 8.232v4.364h4.509l.435-.439 2.174-4.124.648-.437h7.234v-6h-3.938l-.359-.438z"
  in
    svg 
      [ xmlSpace "http://www.w3.org/2000/svg" 
      , Svg.Attributes.width "18" 
      , Svg.Attributes.height "18" 
      , viewBox "0 0 24 24"
      ]
      [ path 
        [ d svgpath ] 
        [] 
      ]

viewTitle: Model -> Html Msg
viewTitle model =
  h1 [ class "site-title" ] [ text model.siteInformation.title ]

loading : String -> Html msg
loading message = 
    span [ class "loading-icon" ] [ text message ]

templateHome : Model -> List (Html Msg) -> List (Html Msg)
templateHome model content =
    [ div [ class "container navbar-container" ] 
      [ viewMenu model.menu
      , viewSocialLinks model 
      ]
    , div [ class "container title-container" ]
      [ viewTitle model
      ]
    ] 
    ++ content
    ++ [
    div [ class "container footer-container"]
      [ viewSocialLinks model
      ]
    ]