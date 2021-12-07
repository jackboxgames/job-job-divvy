package jackboxgames.jobgame.utils
{
    import jackboxgames.utils.*;
    
    import jackboxgames.jobgame.*;
    import jackboxgames.jobgame.model.*;
    
    public class StashManager
    {
        private static var _instance:StashManager;
        public static function get instance():StashManager
        {
            if (!_instance)
            {
                _instance = new StashManager();
            }
            return _instance;
        }
        
        private var _phrasesByAuthor:PerPlayerContainer;
        
        private var _players:Array;
        private var _shuffledPlayers:Array;
        private var _divvyOffset:int;
        private var _reuseOffset:int;
        private var _reusedRoundOnePhrases:PerPlayerContainer;
        
        public function StashManager()
        {
            _phrasesByAuthor = new PerPlayerContainer();
            _reusedRoundOnePhrases = new PerPlayerContainer();
        }
        
        public function setupForNewGame(players:Array):void
        {
            _players = players;
            _shuffledPlayers = ArrayUtil.shuffled(_players);
            _divvyOffset = 1;
            _reuseOffset = -2;
            
            _reusedRoundOnePhrases.reset();
            _phrasesByAuthor.reset();
            for each (var p:Player in _players)
            {
                _phrasesByAuthor.setDataForPlayer(p, []);
            }
        }
        
        public function addPhrases(author:Player, phrases:Array):void
        {
            _phrasesByAuthor.setDataForPlayer(author, _phrasesByAuthor.getDataForPlayer(author).concat(phrases));
        }
        
        private function _divvy(phrases:PerPlayerContainer, round:String):void
        {
            var numToDivvy:int = ArrayUtil.flatten(phrases.getAllData()).length / _shuffledPlayers.length;
            for (var i:int = 0; i < numToDivvy; i++)
            {
                for (var j:int = 0; j < _shuffledPlayers.length; j++)
                {
                    var receivingPlayer:Player = _shuffledPlayers[j];
                    var givingPlayer:Player = ArrayUtil.getElementWrap(_shuffledPlayers, j + _divvyOffset);
                    receivingPlayer.addPhrase(phrases.getDataForPlayer(givingPlayer).shift(), round);
                }
                _divvyOffset++;
                if (_divvyOffset % _shuffledPlayers.length == 0)
                {
                    _divvyOffset++;
                }
            }
        }
        
        private function _reuse(phrases:PerPlayerContainer, round:String):void
        {
            for (var i:int = 0; i < _shuffledPlayers.length; i++)
            {
                var receivingPlayer:Player = _shuffledPlayers[i];
                var givingPlayer:Player = ArrayUtil.getElementWrap(_shuffledPlayers, i + _reuseOffset);
                var options:Array = phrases.getDataForPlayer(givingPlayer).filter(
                    function(phrase:Phrase, ...args):Boolean
                    {
                        return phrase.author != receivingPlayer;
                    }
                );
                var chosenPhrase:Phrase = ArrayUtil.getRandomElement(options);
                ArrayUtil.removeElementFromArray(phrases.getDataForPlayer(givingPlayer), chosenPhrase);
                receivingPlayer.addPhrase(chosenPhrase, round);
            }
            _reuseOffset--;
            if (_reuseOffset % _shuffledPlayers.length == 0)
            {
                _reuseOffset--;
            }
        }
        
        public function divvyRoundOneWords():void
        {
            var phrasesForThisRound:PerPlayerContainer = new PerPlayerContainer();
            for each (var p:Player in _players)
            {
                phrasesForThisRound.setDataForPlayer(p, _phrasesByAuthor.getDataForPlayer(p).slice(0, 3));
            }
            
            _divvy(phrasesForThisRound, GameConstants.ROUND_ONE);
        }
        
        public function divvyRoundTwoWords():void
        {
            var newPhrases:PerPlayerContainer = new PerPlayerContainer();
            for each (var p1:Player in _players)
            {
                newPhrases.setDataForPlayer(p1, _phrasesByAuthor.getDataForPlayer(p1).slice(3, 5));
            }
            _divvy(newPhrases, GameConstants.ROUND_TWO);
            
            for each (var p2:Player in _players)
            {
                _reusedRoundOnePhrases.setDataForPlayer(p2, p2.roundOneStash.slice());
            }
            _reuse(_reusedRoundOnePhrases, GameConstants.ROUND_TWO);
        }
        
        public function divvyRoundThreeWords():void
        {
            var newPhrases:PerPlayerContainer = new PerPlayerContainer();
            for each (var p1:Player in _players)
            {
                newPhrases.setDataForPlayer(p1, _phrasesByAuthor.getDataForPlayer(p1).slice(-1));
            }
            _divvy(newPhrases, GameConstants.ROUND_THREE);
            
            _reuse(_reusedRoundOnePhrases, GameConstants.ROUND_THREE);
            
            var reusedRoundTwoPhrases:PerPlayerContainer = new PerPlayerContainer();
            for each (var p2:Player in _players)
            {
                reusedRoundTwoPhrases.setDataForPlayer(p2, p2.roundTwoStash.slice(0, 2));
            }
            _reuse(reusedRoundTwoPhrases, GameConstants.ROUND_THREE);
        }
    }
}
