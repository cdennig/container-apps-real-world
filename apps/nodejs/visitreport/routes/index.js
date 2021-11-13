const {
    listReportsSchema,
    createReportsSchema,
    readReportsSchema,
    deleteReportsSchema,
    updateReportsSchema,
    statsByContactSchema,
    statsOverallSchema,
    statsTimelineSchema
} = require('../schemas/reports');


const {
    listReportsHandler,
    createReportsHandler,
    deleteReportsHandler,
    readReportsHandler,
    updateReportsHandler,
    statsByContactHandler,
    statsOverallHandler,
    statsTimelineHandler
} = require('../handler/reports');

module.exports = async function (fastify, opts) {
    fastify.route({
        method: 'GET',
        url: '/',
        handler: async function(request, reply) {
            reply.code(200).send();
        }
    });

    fastify.route({
        method: 'GET',
        url: '/api/reports',
        schema: listReportsSchema,
        handler: listReportsHandler
    });

    fastify.route({
        method: 'POST',
        url: '/api/reports',
        schema: createReportsSchema,
        handler: createReportsHandler
    });

    fastify.route({
        method: 'GET',
        url: '/api/reports/:id',
        schema: readReportsSchema,
        handler: readReportsHandler
    });

    fastify.route({
        method: 'PUT',
        url: '/api/reports/:id',
        schema: updateReportsSchema,
        handler: updateReportsHandler
    });
    
    fastify.route({
        method: 'DELETE',
        url: '/api/reports/:id',
        schema: deleteReportsSchema,
        handler: deleteReportsHandler
    });

    // Stats
    
    fastify.route({
        method: 'GET',
        url: '/api/stats/timeline',
        schema: statsTimelineSchema,
        handler: statsTimelineHandler
    });

    fastify.route({
        method: 'GET',
        url: '/api/stats/:contactid',
        schema: statsByContactSchema,
        handler: statsByContactHandler
    });

    fastify.route({
        method: 'GET',
        url: '/api/stats',
        schema: statsOverallSchema,
        handler: statsOverallHandler
    });
};