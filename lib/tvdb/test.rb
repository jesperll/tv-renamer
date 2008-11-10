#!/usr/bin/env ruby
#
#  Created by Bodaniel Jeanes (me@bjeanes.com) on 2008-05-27.
#  Copyright (c) 2008. All rights reserved.

require 'test/unit'
require 'tvdb'

class TestTvdb < Test::Unit::TestCase  
  def test_search_returns_array
    assert_instance_of(Array, api.getSeries("My Name Is Earl"))
  end
  
  def test_sucessful_search_results_contain_series_objects
    assert_instance_of(Tvdb::Series, api.getSeries("My Name Is Earl").first)
  end
  
  private
  def api
    @api ||= Tvdb.new
  end
end

class TestTvdbSeries < Test::Unit::TestCase
  def test_create_from_id_returns_valid_object
    series = Tvdb::Series.new(75397)
    
    assert_instance_of(Tvdb::Series, series)
    assert_equal("My Name Is Earl", series.name)
    assert_equal("2005-09-01", series.first_aired)
  end
  
  # http://www.thetvdb.com/wiki/index.php/API:GetSeries
  def test_create_from_getseries_search_node_returns_valid_object
    doc = Document.new open("http://www.thetvdb.com/api/GetSeries.php?seriesname=My+Name+Is+Earl")

    series = Tvdb::Series.new doc.elements["Data/Series"]
    assert_equal("My Name Is Earl", series.name)
  end
  
  # http://www.thetvdb.com/wiki/index.php/API:Base_Series_Record
  def test_create_from_base_series_record_returns_valid_object
    doc = Document.new open("http://www.thetvdb.com/api/88DD19AA90DD8AAE/series/75397/en.xml")
    series = Tvdb::Series.new(doc)
    
    assert_instance_of(Tvdb::Series, series)
    assert_equal("My Name Is Earl", series.name)
  end
  
  # http://www.thetvdb.com/wiki/index.php/API:Full_Series_Record
  def test_create_from_full_series_record_returns_valid_object_with_episodes
    doc = Document.new open("http://www.thetvdb.com/api/88DD19AA90DD8AAE/series/75397/all/en.xml")
    series = Tvdb::Series.new(doc)
    assert_instance_of(Tvdb::Series, series)
    assert_equal("My Name Is Earl", series.name)
    # bypass getter to make sure they aren't fetched
    assert_not_equal(0, series.instance_variable_get("@episodes").size)
  end
end

class TestTvdbEpisode < Test::Unit::TestCase
  
  # http://www.thetvdb.com/wiki/index.php/API:Base_Episode_Record
  def test_create_from_base_episode_record_returns_valid_object
    #:id, :season_number, :number, :name, :overview, :air_date, :thumb
    doc = Document.new open("http://www.thetvdb.com/api/88DD19AA90DD8AAE/series/75397/default/2/5/en.xml")
    
    episode = Tvdb::Episode.new(doc)
    
    assert_instance_of(Tvdb::Episode, episode)
    assert_equal("Van Hickey", episode.name)
    assert_equal(16331, episode.season_id)
    assert_equal(2, episode.season)
    assert_equal(5, episode.number)
  end

  # http://www.thetvdb.com/wiki/index.php/API:GetEpisodeByAirDate
  def test_create_from_airdate
    series = Tvdb::Series.new(75397)
    episode = series.episode("2006-10-19")    

    assert_instance_of(Tvdb::Episode, episode)
    assert_equal("Van Hickey", episode.name)
    assert_equal(16331, episode.season_id)
    assert_equal(2, episode.season)
    assert_equal(5, episode.number)
  end 
end
