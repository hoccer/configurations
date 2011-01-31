module God
  module Conditions

    class MongoConnections < PollCondition
      attr_accessor :above

      def initialize
        super
        self.above = nil
      end
      
      def valid?
        valid = true
        valid &= complain("Attribute 'above' must be specified", self) if self.above.nil?
        valid
      end

      def test
        actual = `mongo --eval "db.serverStatus().connections.current" --quiet`
        if actual.to_i > self.above.to_i
          self.info = "db connections out of bounds #{actual.to_i}/#{above}"
          true
        else
          self.info = "db connections within bounds #{actual.to_i}/#{above}"
          false
        end
      end
    end
  end
end
