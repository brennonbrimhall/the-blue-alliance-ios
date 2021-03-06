import CoreData
import TBAKit
import Foundation

extension MatchAlliance: Managed {

    /**
     Returns team keys for the alliance.
     */
    public var teamKeys: [String] {
        return (teams!.array as? [TeamKey])?.map({ $0.key! }) ?? []
    }

    /**
     Returns team keys for DQ'd teams for the alliance.
     */
    public var dqTeamKeys: [String] {
        return (dqTeams?.array as? [TeamKey])?.map({ $0.key! }) ?? []
    }

    /**
     Insert a Match Alliance with values from a TBAKit Match Alliance model in to the managed object context.

     - Important: This method does not manage setting up a Match Alliance's relationship to a Match.

     - Parameter model: The TBAKit Match Alliance representation to set values from.

     - Parameter allianceKey: The `key` for the alliance - usually the alliance color (red, blue).

     - Parameter matchKey: The `key` for the Match the Match Alliance belongs to.

     - Parameter context: The NSManagedContext to insert the Match Alliance in to.

     - Returns: The inserted Match Alliance.
     */
    public static func insert(_ model: TBAMatchAlliance, allianceKey: String, matchKey: String, in context: NSManagedObjectContext) -> MatchAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(MatchAlliance.allianceKey), allianceKey,
                                    #keyPath(MatchAlliance.match.key), matchKey)

        return findOrCreate(in: context, matching: predicate) { (matchAlliance) in
            // Required: allianceKey, score, teams
            matchAlliance.allianceKey = allianceKey

            // Match scores for unplayed matches are returned as -1 from the API
            if model.score > -1 {
                matchAlliance.score = model.score as NSNumber
            } else {
                matchAlliance.score = nil
            }

            // Don't use updateToManyRelationship to set these up, since Team Key's will never be orphaned.
            // Additionally, updateToManyRelationship doesn't support ordered sets

            matchAlliance.teams = NSOrderedSet(array: model.teams.map({ (key) -> TeamKey in
                return TeamKey.insert(withKey: key, in: context)
            }))

            if let surrogateTeams = model.surrogateTeams {
                matchAlliance.surrogateTeams = NSOrderedSet(array: surrogateTeams.map({ (key) -> TeamKey in
                    return TeamKey.insert(withKey: key, in: context)
                }))
            } else {
                matchAlliance.surrogateTeams = nil
            }

            if let dqTeams = model.dqTeams {
                matchAlliance.dqTeams = NSOrderedSet(array: dqTeams.map({ (key) -> TeamKey in
                    return TeamKey.insert(withKey: key, in: context)
                }))
            } else {
                matchAlliance.dqTeams = nil
            }
        }
    }

    public var isOrphaned: Bool {
        return match == nil
    }

}
